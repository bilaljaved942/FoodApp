"""Storage Service — DigitalOcean Spaces (S3-compatible)."""
import uuid
import boto3
from botocore.exceptions import ClientError
from fastapi import HTTPException, UploadFile
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


def _get_spaces_client():
    return boto3.client(
        "s3",
        region_name=settings.DO_SPACES_REGION,
        endpoint_url=settings.DO_SPACES_ENDPOINT,
        aws_access_key_id=settings.DO_SPACES_KEY,
        aws_secret_access_key=settings.DO_SPACES_SECRET,
    )


async def upload_file(file: UploadFile, folder: str = "uploads") -> str:
    """
    Upload a file to DigitalOcean Spaces.
    Returns the public CDN URL.
    """
    # Validate content type
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=400, detail=f"File type not allowed. Allowed: {ALLOWED_IMAGE_TYPES}")

    # Read file content
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File size exceeds 5MB limit")

    # Generate unique filename
    ext = file.filename.rsplit(".", 1)[-1].lower() if "." in file.filename else "jpg"
    filename = f"{folder}/{uuid.uuid4().hex}.{ext}"

    try:
        client = _get_spaces_client()
        client.put_object(
            Bucket=settings.DO_SPACES_BUCKET,
            Key=filename,
            Body=content,
            ContentType=file.content_type,
            ACL="public-read",
        )
        # Return CDN URL
        cdn_url = f"{settings.DO_SPACES_CDN_ENDPOINT}/{filename}"
        logger.info(f"Uploaded file to Spaces: {cdn_url}")
        return cdn_url
    except ClientError as e:
        logger.error(f"Spaces upload error: {e}")
        raise HTTPException(status_code=500, detail="File upload failed")


async def delete_file(file_url: str):
    """Delete a file from DigitalOcean Spaces by its URL."""
    try:
        cdn_prefix = settings.DO_SPACES_CDN_ENDPOINT + "/"
        spaces_prefix = settings.DO_SPACES_ENDPOINT + f"/{settings.DO_SPACES_BUCKET}/"
        key = None
        if file_url.startswith(cdn_prefix):
            key = file_url[len(cdn_prefix):]
        elif file_url.startswith(spaces_prefix):
            key = file_url[len(spaces_prefix):]
        if not key:
            return
        client = _get_spaces_client()
        client.delete_object(Bucket=settings.DO_SPACES_BUCKET, Key=key)
        logger.info(f"Deleted file from Spaces: {key}")
    except Exception as e:
        logger.warning(f"Spaces delete skipped: {e}")

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String storeId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? notes;

  const CartItem({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.notes,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? storeId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? notes,
  }) =>
      CartItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        storeId: storeId ?? this.storeId,
        name: name ?? this.name,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl ?? this.imageUrl,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props =>
      [id, productId, storeId, name, price, quantity, imageUrl, notes];
}

// ─────────────────────────────────────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────────────────────────────────────

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartAddItemEvent extends CartEvent {
  final String productId;
  final String storeId;
  final String name;
  final double price;
  final String? imageUrl;

  const CartAddItemEvent({
    required this.productId,
    required this.storeId,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [productId, storeId, name, price];
}

class CartRemoveItemEvent extends CartEvent {
  final String itemId;
  const CartRemoveItemEvent(this.itemId);
  @override
  List<Object> get props => [itemId];
}

class CartUpdateQuantityEvent extends CartEvent {
  final String itemId;
  final int quantity;
  const CartUpdateQuantityEvent({required this.itemId, required this.quantity});
  @override
  List<Object> get props => [itemId, quantity];
}

class CartClearEvent extends CartEvent {
  const CartClearEvent();
}

class CartUpdateNotesEvent extends CartEvent {
  final String itemId;
  final String notes;
  const CartUpdateNotesEvent({required this.itemId, required this.notes});
  @override
  List<Object> get props => [itemId, notes];
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class CartState extends Equatable {
  final List<CartItem> items;
  final String? storeId; // cart is tied to a single store
  final String? couponCode;
  final double? discountAmount;

  const CartState({
    this.items = const [],
    this.storeId,
    this.couponCode,
    this.discountAmount,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  double get deliveryFee => subtotal >= 30.0 ? 0.0 : 2.99;

  double get discount => discountAmount ?? 0.0;

  double get serviceFee => subtotal * 0.05;

  double get total => subtotal + deliveryFee + serviceFee - discount;

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    String? storeId,
    String? couponCode,
    double? discountAmount,
  }) =>
      CartState(
        items: items ?? this.items,
        storeId: storeId ?? this.storeId,
        couponCode: couponCode ?? this.couponCode,
        discountAmount: discountAmount ?? this.discountAmount,
      );

  @override
  List<Object?> get props => [items, storeId, couponCode, discountAmount];
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────────────────────────────────────────

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final _uuid = const Uuid();

  CartBloc() : super(const CartState()) {
    on<CartAddItemEvent>(_onAddItem);
    on<CartRemoveItemEvent>(_onRemoveItem);
    on<CartUpdateQuantityEvent>(_onUpdateQuantity);
    on<CartClearEvent>(_onClear);
    on<CartUpdateNotesEvent>(_onUpdateNotes);
  }

  void _onAddItem(CartAddItemEvent event, Emitter<CartState> emit) {
    // Different store — clear cart first
    if (state.storeId != null && state.storeId != event.storeId) {
      emit(const CartState());
    }

    final existingIndex =
        state.items.indexWhere((i) => i.productId == event.productId);

    if (existingIndex >= 0) {
      // Increment quantity
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex]
          .copyWith(quantity: updatedItems[existingIndex].quantity + 1);
      emit(state.copyWith(items: updatedItems));
    } else {
      final newItem = CartItem(
        id: _uuid.v4(),
        productId: event.productId,
        storeId: event.storeId,
        name: event.name,
        price: event.price,
        quantity: 1,
        imageUrl: event.imageUrl,
      );
      emit(state.copyWith(
        items: [...state.items, newItem],
        storeId: event.storeId,
      ));
    }
  }

  void _onRemoveItem(CartRemoveItemEvent event, Emitter<CartState> emit) {
    final updatedItems = state.items.where((i) => i.id != event.itemId).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateQuantity(CartUpdateQuantityEvent event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(CartRemoveItemEvent(event.itemId));
      return;
    }
    final updatedItems = state.items
        .map((i) => i.id == event.itemId ? i.copyWith(quantity: event.quantity) : i)
        .toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onClear(CartClearEvent event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _onUpdateNotes(CartUpdateNotesEvent event, Emitter<CartState> emit) {
    final updatedItems = state.items
        .map((i) => i.id == event.itemId ? i.copyWith(notes: event.notes) : i)
        .toList();
    emit(state.copyWith(items: updatedItems));
  }
}

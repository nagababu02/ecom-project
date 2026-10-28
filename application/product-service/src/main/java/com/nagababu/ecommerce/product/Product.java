package com.nagababu.ecommerce.product;

import java.math.BigDecimal;

public record Product(long id, String name, String description, BigDecimal price) {
}

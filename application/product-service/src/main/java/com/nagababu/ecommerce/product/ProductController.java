package com.nagababu.ecommerce.product;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final List<Product> products = List.of(
        new Product(1, "Laptop", "Everyday productivity laptop", new BigDecimal("799.99")),
        new Product(2, "Headphones", "Wireless over-ear headphones", new BigDecimal("89.50")),
        new Product(3, "Keyboard", "Compact mechanical keyboard", new BigDecimal("64.00"))
    );

    @GetMapping
    public List<Product> getProducts() {
        return products;
    }

    @GetMapping("/{id}")
    public Product getProduct(@PathVariable long id) {
        return products.stream()
            .filter(product -> product.id() == id)
            .findFirst()
            .orElseThrow(() -> new ResponseStatusException(
                HttpStatus.NOT_FOUND, "Product not found"
            ));
    }
}

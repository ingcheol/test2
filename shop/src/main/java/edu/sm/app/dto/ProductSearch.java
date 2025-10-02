package edu.sm.app.dto;

import lombok.*;
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class ProductSearch {
    String productName;
    int startPrice;
    int endPrice;
    int cateId;
}

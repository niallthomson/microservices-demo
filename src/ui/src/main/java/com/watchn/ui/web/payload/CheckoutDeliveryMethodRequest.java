package com.watchn.ui.web.payload;

import lombok.Data;

import javax.validation.constraints.Pattern;

@Data
public class CheckoutDeliveryMethodRequest {
    @Pattern(regexp = "^[A-Za-z0-9]+$")
    private String token;
}

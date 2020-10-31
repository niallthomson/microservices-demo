package com.watchn.ui.web.payload;

import lombok.Data;

@Data
public class ShippingAddressRequest {
    private String firstName;

    private String lastName;

    private String email;

    private String address1;

    private String address2;

    private String city;

    private String country;

    private String zip;

    private String state;
}

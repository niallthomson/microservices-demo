package com.watchn.ui.web.payload;

import lombok.Data;

@Data
public class OrderRequest {
    private String firstName;

    private String lastName;

    private String email;

    private String address;

    private String address2;

    private String country;

    private String zip;

    private String state;

    private String ccName;

    private String ccNumber;

    private String ccExpiration;

    private String ccCvv;
}

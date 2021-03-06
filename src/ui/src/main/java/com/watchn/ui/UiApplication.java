package com.watchn.ui;

import com.watchn.ui.clients.catalog.ApiClient;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UiApplication {

	private ApiClient client;

	public static void main(String[] args) {
		SpringApplication.run(UiApplication.class, args);
	}

}

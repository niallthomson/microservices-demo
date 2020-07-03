package com.watchn.orders.config.persistence;

import com.watchn.orders.repositories.ReadOnlyRepository;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
import org.springframework.context.annotation.*;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.persistence.EntityManagerFactory;
import javax.sql.DataSource;

@Configuration
@Profile("mysql")
@EnableTransactionManagement
@EnableJpaRepositories(
        entityManagerFactoryRef = "readerEntityManagerFactory",
        transactionManagerRef = "readerTransactionManager",
        includeFilters = @ComponentScan.Filter(ReadOnlyRepository.class),
        basePackages = {
                "com.watchn.orders"
        }
)
public class ReaderConfig {

    @Bean(name = "readerDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.reader")
    public DataSource customerDataSource() {
        return DataSourceBuilder.create().build();
    }

    @Bean(name = "readerEntityManagerFactory")
    public LocalContainerEntityManagerFactoryBean
    entityManagerFactory(
            EntityManagerFactoryBuilder builder,
            @Qualifier("readerDataSource") DataSource dataSource
    ) {
        return builder
                .dataSource(dataSource)
                .packages("com.watchn.orders")
                .persistenceUnit("reader")
                .build();
    }

    @Bean(name = "readerTransactionManager")
    public PlatformTransactionManager customerTransactionManager(
            @Qualifier("readerEntityManagerFactory") EntityManagerFactory customerEntityManagerFactory
    ) {
        return new JpaTransactionManager(customerEntityManagerFactory);
    }
}

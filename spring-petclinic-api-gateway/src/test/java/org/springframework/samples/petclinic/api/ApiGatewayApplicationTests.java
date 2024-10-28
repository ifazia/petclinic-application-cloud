package org.springframework.samples.petclinic.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
@ActiveProfiles("test")
@SpringBootTest
@TestPropertySource(locations = {
    "classpath:spring-petclinic-customers-service/src/test/resources/application-primary.yaml"
    "classpath:spring-petclinic-vets-service/src/test/resources/application-secondary.yaml"
    "classpath:spring-petclinic-visits-service/src/test/resources/application-tertiary.yaml"
})
class ApiGatewayApplicationTests {

	@Test
	void contextLoads() {
	}

}
//just for test
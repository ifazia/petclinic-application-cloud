package org.springframework.samples.petclinic.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@ActiveProfiles("test")
@SpringBootTest
@TestPropertySource(locations = {
    "classpath:application-primary.yaml",
    "classpath:application-secondary.yaml",
    "classpath:application-tertiary.yaml"
})
class ApiGatewayApplicationTests {

	@Test
	void contextLoads() {
	}

}
//just for test
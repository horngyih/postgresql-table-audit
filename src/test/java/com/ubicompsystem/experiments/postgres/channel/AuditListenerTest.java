package com.ubicompsystem.experiments.postgres.channel;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration({ "classpath*:spring/applicationContext-postgres-listener.xml"})
public class AuditListenerTest {

    @Test
    public void defaultTest() throws Exception{
        Thread.sleep(1000000);
    }
}

package com.ubicompsystem.experiments.postgres.channel;


import com.impossibl.postgres.api.jdbc.PGConnection;
import com.impossibl.postgres.api.jdbc.PGNotificationListener;
import org.apache.log4j.Logger;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

public class PGChannelListener {

    final Logger log = Logger.getLogger( PGChannelListener.class );

    DataSource dataSource;
    String channel;
    boolean active;

    public PGChannelListener( DataSource dataSource, String channel ){
        this.dataSource = dataSource;
        this.channel = channel;
    }

    public void init() throws Exception {
        active = true;
        Connection connection = dataSource.getConnection();
        PGNotificationListener listener = new PGNotificationListener() {
            @Override
            public void notification(int processId, String channelName, String payload) {
                log.info( "Received notification: " + payload );
            }
        };

        if( connection instanceof PGConnection ){
            try( PGConnection pgConnection = (PGConnection) connection ) {
                String listenStatement = String.format( "LISTEN %s", channel );
                Statement statement = pgConnection.createStatement();
                statement.execute( listenStatement );
                statement.close();
                pgConnection.addNotificationListener(listener);
                while(active){
                    Thread.sleep(500);
                }
            }
        }
    }

    public void stop(){
        active = false;
    }

}

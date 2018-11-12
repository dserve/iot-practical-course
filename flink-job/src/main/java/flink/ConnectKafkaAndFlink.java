package flink;

import org.apache.flink.api.common.functions.RuntimeContext;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.elasticsearch.*;
import org.apache.flink.streaming.connectors.elasticsearch5.ElasticsearchSink;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer011;
import org.apache.flink.streaming.util.serialization.SimpleStringSchema;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.client.Requests;

import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * Skeleton for a Flink Batch Job.
 *
 * For a full example of a Flink Batch Job, see the WordCountJob.java file in the
 * same package/directory or have a look at the website.
 *
 * You can also generate a .jar file that you can submit on your Flink
 * cluster.
 * Just type
 * 		mvn clean package
 * in the projects root directory.
 * You will find the jar in
 * 		target/kafka-flink-101-1.0-SNAPSHOT.jar
 * From the CLI you can then run
 * 		./bin/flink run -c com.grallandco.demos.BatchJob target/kafka-flink-101-1.0-SNAPSHOT.jar
 *
 * For more information on the CLI see:
 *
 * http://flink.apache.org/docs/latest/apis/cli.html
 */
public class ConnectKafkaAndFlink {

    public static DataStream<String> readFromKafka(StreamExecutionEnvironment env) throws Exception {
        Properties properties = new Properties();
        properties.setProperty("bootstrap.servers", "kafka-internal:9092");
        properties.setProperty("group.id", "flink_consumer");

        DataStream<String> stream = env.addSource(new FlinkKafkaConsumer011<>(
                "testing", new SimpleStringSchema(), properties) );


        return stream;
    }

    public static void writeToElasticsearch(DataStream<String> input) throws UnknownHostException {
        Map<String, String> config = new HashMap<>();
        config.put("cluster.name", "docker-cluster");
        // This instructs the sink to emit after every element, otherwise they would be buffered
        config.put("bulk.flush.max.actions", "1");
        config.put("node.name", "node-1");
        try {
            // Add elasticsearch hosts on startup
            List<InetSocketAddress> transportAddresses = new ArrayList<>();
            transportAddresses.add(new InetSocketAddress("elasticsearch", 9300)); // port is 9300 not 9200 for ES TransportClient

            ElasticsearchSinkFunction<String> indexLog = new ElasticsearchSinkFunction<String>() {
                public IndexRequest createIndexRequest(String element) {
                    String timestamp = ZonedDateTime.now( ZoneOffset.UTC ).format( DateTimeFormatter.ISO_INSTANT );
                    Map<String, String> esJson = new HashMap<>();
                    esJson.put("value", element);
                    esJson.put("timestamp", timestamp);

                    return Requests
                            .indexRequest()
                            .index("testindex")
                            .type("closed")
                            .timestamp(timestamp)
                            .source(esJson);
                }

                @Override
                public void process(String element, RuntimeContext ctx, RequestIndexer indexer) {
                    indexer.add(createIndexRequest(element));
                }
            };

            ElasticsearchSink esSink = new ElasticsearchSink(config, transportAddresses, indexLog);
            input.addSink(esSink);
        } catch (Exception e) {
            System.out.println(e);
        }
    }

    public static void main(String[] args) throws Exception {
        // set up the batch execution environment
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        /**
         * Here, you can start creating your execution plan for Flink.
         *
         * Start with getting some data from the environment, like
         * 	env.readTextFile(textPath);
         *
         * then, transform the resulting DataSet<String> using operations
         * like
         * 	.filter()
         * 	.flatMap()
         * 	.join()
         * 	.coGroup()
         *
         * and many more.
         * Have a look at the programming guide for the Java API:
         *
         * http://flink.apache.org/docs/latest/apis/batch/index.html
         *
         * and the examples
         *
         * http://flink.apache.org/docs/latest/apis/batch/examples.html
         *
         */

        DataStream<String> stream = readFromKafka(env);

        writeToElasticsearch(stream);

        // execute program
        env.execute();
    }
}

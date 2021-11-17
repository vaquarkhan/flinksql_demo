package huangxu.chase.flinksql.demo;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * @Author： huangxu.chase
 * Email: huangxu@smail.nju.edu.cn
 * @Date： 2021/11/16
 * @description：
 */
public class SourceGenerator {
    private static final long SPEED = 1000L;

    public static void main(String[] args) {
        long speed = SPEED;
        if(args.length > 0){
            speed = Long.valueOf(args[0]);
        }
        long delay = 1000_000 / speed;

        try {
            InputStream dataStream = SourceGenerator.class.getClassLoader().getResourceAsStream("user_behavior.log");
            BufferedReader reader = new BufferedReader(new InputStreamReader(dataStream));
            long start = System.nanoTime();
            while (reader.ready()) {
                String line = reader.readLine();
                line = line.replace("T0", " 0");
                line = line.replace("T1", " 1");
                line = line.replace("Z", "");

                if (line.charAt(line.length() - 10) == ' '){
                    line = line.substring(0, line.length() - 9) + "0" + line.substring(line.length() - 9);
                }

                System.out.println(line);   // print to std out, then input to kafka by linux pipeline.

                Thread.sleep(1);      // 1 record, sleep 1ms
//                long end = System.nanoTime();
//                long diff = start - end;
//                while (diff < delay * 1000){
//                    Thread.sleep(1);   // sleep 1 ms
//                    end = System.nanoTime();
//                    diff = end - start;
//                }
//                start = end;
            }
        } catch (IOException e){
            throw new RuntimeException(e);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

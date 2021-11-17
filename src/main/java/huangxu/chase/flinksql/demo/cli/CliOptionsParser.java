package huangxu.chase.flinksql.demo.cli;


import org.apache.commons.cli.*;

/**
 * @Author： huangxu.chase
 * Email: huangxu@smail.nju.edu.cn
 * @Date： 2021/11/16
 * @description：
 */
public class CliOptionsParser {
    public static final Option OPTION_WORKING_SPACE = Option.builder("w").required(true).longOpt("working_space")
            .numberOfArgs(1).argName("workding space dir").desc("The workding space dir").build();

    public static final Option OPTION_SQL_FILE = Option.builder("f").required(true).longOpt("file").
            numberOfArgs(1).argName("SQL file path").desc("The SQL file path").build();

    public static final Options CLIENT_OPTIONS = getClientOptions(new Options());

    private static Options getClientOptions(Options options) {
        options.addOption(OPTION_SQL_FILE);
        options.addOption(OPTION_WORKING_SPACE);
        return options;
    }

    public static CliOptions parseClient(String []args){
        if (args.length < 1){
            throw new RuntimeException("./sql_submit -w <work_space_dir> -f <sql-file>");
        }

        try{
            DefaultParser parser = new DefaultParser();
            CommandLine line = parser.parse(CLIENT_OPTIONS, args, true);
            return new CliOptions(line.getOptionValue(CliOptionsParser.OPTION_SQL_FILE.getOpt()),
                    line.getOptionValue(CliOptionsParser.OPTION_WORKING_SPACE.getOpt()));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return null;
    }
}

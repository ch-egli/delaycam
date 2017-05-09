package ch.egli.delaycam.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.List;

/**
 * TODO: Describe
 *
 * @author Christian Egli
 * @since 5/9/17.
 */
@RestController
public class DelayController {
    private static final Logger LOGGER = LoggerFactory.getLogger(DelayController.class);

    private static Integer MIN_DELAY = 5;
    private static Integer MAX_DELAY = 60;

    private static Integer ADJUST_VALUE = 3; // default delay in seconds

    @RequestMapping(value="/delay", method= RequestMethod.GET)
    public String getDelay() throws IOException {

        // get the value from file
        Integer delayInSeconds = getDelayFromFile();

        LOGGER.info("delay read from file: {}", delayInSeconds);
        return delayInSeconds.toString();
    }

    @RequestMapping(value="/delay/{delayInSeconds}", method= RequestMethod.GET)
    public String changeDelay(@PathVariable Integer delayInSeconds) throws IOException {
        if (delayInSeconds < MIN_DELAY) {
            LOGGER.warn("delay is too low > setting it to {}", MIN_DELAY);
            delayInSeconds = MIN_DELAY;
        } else if (delayInSeconds > MAX_DELAY) {
            LOGGER.warn("delay is too high > setting it to {}", MAX_DELAY);
            delayInSeconds = MAX_DELAY;
        }

        // set...
        LOGGER.info("setting delay to {}", delayInSeconds);
        setDelayToFile(delayInSeconds);
        return delayInSeconds.toString();
    }

    private Integer getDelayFromFile() throws IOException {
        List<String> lines = Files.readAllLines(Paths.get("delay.txt"));
        int result = 0;
        if (lines != null) {
            String firstLine = lines.get(0);
            try {
                result = Integer.parseInt(firstLine);
            } catch (NumberFormatException e) {
                LOGGER.warn("invalid delay value in file: {}", firstLine);
            }

        }

        result = result / 1000;
        result = result + ADJUST_VALUE;
        return result;
    }

    private void setDelayToFile(Integer delayInSeconds) throws IOException {
        delayInSeconds = delayInSeconds - ADJUST_VALUE;
        Integer delayInMillis = 1000 * delayInSeconds;
        Files.write(Paths.get("delay.txt"), delayInMillis.toString().getBytes(Charset.forName("UTF-8")), StandardOpenOption.CREATE);
    }

}

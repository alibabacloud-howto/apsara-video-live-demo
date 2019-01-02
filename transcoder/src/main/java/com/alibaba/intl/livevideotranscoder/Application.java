package com.alibaba.intl.livevideotranscoder;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Application entry-point.
 *
 * @author Alibaba Cloud
 */
@SpringBootApplication
@Configuration
@EnableScheduling
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Bean
    public TaskExecutor ffmpegLauncherThreadPoolTaskExecutor() {
        return new SimpleAsyncTaskExecutor("ffmpeg_launcher");
    }
}

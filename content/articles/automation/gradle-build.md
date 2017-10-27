Title:       Jenkins gradle build succeeded with failure
Author:      Jan
Date: 	     2017-09-21 22:00
Slug:	     gradle-build
Tags: 	     gradle, android, jenkins, FAILURE, Already, finished
Modified:    2017-09-21
Status:	     published

Today we bumped into an interesting issue in the jenkins builds of some android based applications. The gradle commands succeeded but then suddenly failed the build with this most cryptic message ever:

```
BUILD SUCCESSFUL

Total time: 1 mins 20.492 secs

FAILURE: Build failed with an exception.

* What went wrong:
Already finished

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.
[Pipeline] }
```

Since this came out of nowhere without any modification on the build servers we where flabbergasted since the builds ran fine on our local machines.

So we took the suggestion of the stacktrace option and ran the build again:


```

14:00:31.371 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] FAILURE: Build failed with an exception.
14:00:31.372 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter]
14:00:31.372 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] * What went wrong:
14:00:31.372 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] Already finished
14:00:31.372 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter]
14:00:31.372 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] * Exception is:
14:00:31.373 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] java.lang.IllegalStateException: Already finished
14:00:31.373 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at com.google.common.base.Preconditions.checkState(Preconditions.java:174)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at com.android.builder.profile.ProcessProfileWriter.finishAndMaybeWrite(ProcessProfileWriter.java:121)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at com.android.builder.profile.ProcessProfileWriterFactory.shutdownAndMaybeWrite(ProcessProfileWriterFactory.java:52)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at com.android.build.gradle.internal.profile.ProfilerInitializer$ProfileShutdownListener.completed(ProfilerInitializer.java:110)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at sun.reflect.GeneratedMethodAccessor660.invoke(Unknown Source)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at java.lang.reflect.Method.invoke(Method.java:498)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.dispatch.ReflectionDispatch.dispatch(ReflectionDispatch.java:35)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.dispatch.ReflectionDispatch.dispatch(ReflectionDispatch.java:24)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.event.DefaultListenerManager$ListenerDetails.dispatch(DefaultListenerManager.java:249)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.event.DefaultListenerManager$ListenerDetails.dispatch(DefaultListenerManager.java:229)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.event.AbstractBroadcastDispatch.dispatch(AbstractBroadcastDispatch.java:44)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.event.DefaultListenerManager$EventBroadcast$ListenerDispatch.dispatch(DefaultListenerManager.java:221)
14:00:31.374 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.event.DefaultListenerManager$EventBroadcast$ListenerDispatch.dispatch(DefaultListenerManager.java:209)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.dispatch.ProxyDispatchAdapter$DispatchingInvocationHandler.invoke(ProxyDispatchAdapter.java:93)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at com.sun.proxy.$Proxy17.completed(Unknown Source)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.initialization.DefaultGradleLauncher.stop(DefaultGradleLauncher.java:226)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.exec.InProcessBuildActionExecuter.execute(InProcessBuildActionExecuter.java:44)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.exec.InProcessBuildActionExecuter.execute(InProcessBuildActionExecuter.java:26)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.tooling.internal.provider.ContinuousBuildActionExecuter.execute(ContinuousBuildActionExecuter.java:75)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.tooling.internal.provider.ContinuousBuildActionExecuter.execute(ContinuousBuildActionExecuter.java:49)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.tooling.internal.provider.ServicesSetupBuildActionExecuter.execute(ServicesSetupBuildActionExecuter.java:49)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.tooling.internal.provider.ServicesSetupBuildActionExecuter.execute(ServicesSetupBuildActionExecuter.java:31)
14:00:31.375 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.ExecuteBuild.doBuild(ExecuteBuild.java:67)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.BuildCommandOnly.execute(BuildCommandOnly.java:36)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.WatchForDisconnection.execute(WatchForDisconnection.java:47)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.ResetDeprecationLogger.execute(ResetDeprecationLogger.java:26)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.RequestStopIfSingleUsedDaemon.execute(RequestStopIfSingleUsedDaemon.java:34)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.ForwardClientInput$2.call(ForwardClientInput.java:74)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.ForwardClientInput$2.call(ForwardClientInput.java:72)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.util.Swapper.swap(Swapper.java:38)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.ForwardClientInput.execute(ForwardClientInput.java:72)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.376 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.LogAndCheckHealth.execute(LogAndCheckHealth.java:55)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.LogToClient.doBuild(LogToClient.java:60)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.BuildCommandOnly.execute(BuildCommandOnly.java:36)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.EstablishBuildEnvironment.doBuild(EstablishBuildEnvironment.java:72)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.BuildCommandOnly.execute(BuildCommandOnly.java:36)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.api.DaemonCommandExecution.proceed(DaemonCommandExecution.java:120)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.exec.StartBuildOrRespondWithBusy$1.run(StartBuildOrRespondWithBusy.java:50)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.launcher.daemon.server.DaemonStateCoordinator$1.run(DaemonStateCoordinator.java:297)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.concurrent.ExecutorPolicy$CatchAndRecordFailures.onExecute(ExecutorPolicy.java:63)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at org.gradle.internal.concurrent.StoppableExecutorImpl$1.run(StoppableExecutorImpl.java:46)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
14:00:31.377 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
14:00:31.378 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter] 	at java.lang.Thread.run(Thread.java:745)
14:00:31.378 [ERROR] [org.gradle.internal.buildevents.BuildExceptionReporter]
```

but this didn't make us giving any more clue. So decided to log on to the build node and trying to remove the gradle caches on suggestion of a colleague:

```
$ rm /home/jenkins/.gradle/caches/* -rf
```

but no solution neither. Checked out the repository to commit of the latest successful build and tried to run the command from there manually but still no success.

After reading many other gradle issues I came to one indicating killing the gradle daemons could solve the mystery. So we went ahead and killed the daemons on the build node.

```
jenkins   6341 33.9  7.9 14954276 2625892 ?    Ssl  18:11  58:59 /usr/lib/jvm/java-8-openjdk-amd64/bin/java -Xmx1536m -Dfile.encoding=UTF-8 -Duser.country=US -Duser.language=en -Duser.variant -cp /home/jenkins/.gradle/wrapper/dists/gradle-3.5-all/exhrs6ca08n232b14ue48lbye/gradle-3.5/lib/gradle-launcher-3.5.jar org.gradle.launcher.daemon.bootstrap.GradleDaemon 3.5
jenkins  10631 19.3  6.5 14449300 2164472 ?    Ssl  18:48  26:25 /usr/lib/jvm/java-8-openjdk-amd64/bin/java -Xmx1536m -Dfile.encoding=UTF-8 -Duser.country=US -Duser.language=en -Duser.variant -cp /home/jenkins/.gradle/wrapper/dists/gradle-3.4.1-all/c3ib5obfnqr0no9szq6qc17do/gradle-3.4.1/lib/gradle-launcher-3.4.1.jar org.gradle.launcher.daemon.bootstrap.GradleDaemon 3.4.1
```

And reran the build manually which succeeded, when re-triggering the job it succeeded. Victory! We assumed those daemons where stopped right after the execution but as we noticed this wasn't the case.

I wrote this post since I couldn't find anything related to the message and maybe I can help others gaining time resolving the issue since as always such things comes on days you haven't time for them..

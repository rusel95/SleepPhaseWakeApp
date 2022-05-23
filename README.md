# Sleep Phase Wake App (only for WatchOS)

WatchOS App for waking up using Sleep Phase detection via accelerometer

What are app Developments Steps for creating of Minimum Valuable Product:

1) Create part of the app wich works in the background:
 - UI-part:
    * Active/Inactive states screens;
 - background-runtime execution;

2) Calculate current Sleep Phase using acelerometer data:
 - measure moves via acceleration;
 - use number of moves/hour for Sleep Phase detection;
 - use HealthKit?
 - some MLKit?

After MVP (1.0) will be finished it will be requred to work on enhancmemnts of basic SleepPhase & Wakeup algorithms:
- try to make marks per wake ups

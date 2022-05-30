# Sleep Phase Wake App (only for WatchOS)

WatchOS App for waking up using Sleep Phase detection via accelerometer

What are app Developments Steps for creating of Minimum Valuable Product:

1. Create part of the app wich works in the background:
  - ~~UI-part~~:
    * ~~Active/Inactive states screens~~;
    * ~~finish screen~~;
  - ~~background-runtime execution~~;

2. Calculate current Sleep Phase using acelerometer data:
    - ~~measure moves via acceleration~~;
    - ~~use first move per Wake Up interval as a trigger for Wake Up~~;

---

Ideas for further Sleep Phase Detection:
- use number of moves/hour for Sleep Phase detection
- try to make marks per wake ups;
- use Heart Rate for Sleep Detection;
- use HealthKit's Sleep Data for Detection;

# Sleep Phase Wake App for WatchOS

## Goal: wake up easier while less sleep, increase sleep quality

### SwiftUI + MVVM WatchOS App for waking up using Sleep Phase detection via accelerometer (very basic shaking detection for now)
Later Apple's native HKCategorySleepAnalysis will be added for detection enhancement

---

## App Development Steps for creating of MVP (Minimum Valuable Product):
  
1. ~~UI-part~~:
    - ~~inactive state screen (selection wake up time)~~;
    
    ![alt text](https://github.com/rusel95/SleepPhaseWakeApp/blob/main/SleepPhaseWakeApp%20WatchKit%20Extension/Resources/Examples/notstartedsession.PNG)
    
    - ~~active states screen~~(showing processing screen);
    
    ![alt text](https://github.com/rusel95/SleepPhaseWakeApp/blob/main/SleepPhaseWakeApp%20WatchKit%20Extension/Resources/Examples/startedsession.PNG)
        
    - ~~finish screen (wake up message)~~;
    
    ![alt text](https://github.com/rusel95/SleepPhaseWakeApp/blob/main/SleepPhaseWakeApp%20WatchKit%20Extension/Resources/Examples/wakeup.PNG)
    
    - ~~MVVM-arhitecture applying~~;

2. ~~Create processing part of the app~~:
    - ~~background-runtime execution for some period of time~~(30 minutes is maximum possible duration - OS restrictions);
    - ~~background states handling~~;
    - ~~making possible to have some calculations several times/minute~~(every second for now);
  
3. ~~Sleep Phase basic calculation~~(using only acelerometer data for now):
    - ~~measure moves via acceleration~~;
    - ~~use first move per Wake Up interval as a trigger for Wake Up~~(used total acceleration for this need);

---

## Next Steps:

1. Beta-testing: 
    - sharing between several internal testers; 
    - approve the idea by receiging more positive feedbacks then negative;
    - fixing of minor bugs;
   
2. Additional UI-functionality;

3. Redesign;

4. SleepPhase algorhytm detection improvements;

5. Alpha-testing;

6. Companion iOS-App - showing detailed graphs (with sleep stages and/or sleep quality and/or sleep durations - HealthKit);
        
---

## Ideas for further Sleep Phase Detection:
- use number of moves/hour for Sleep Phase detection
- try to make marks per wake ups;
- use Heart Rate for Sleep Detection;

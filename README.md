# AOSP auto brightness emulator

MATLAB scripts I used when writing the [blog artical](https://blog.xzr.moe/archives/152/) about aosp auto brightness.

This is simply a reproduce of codes in [BrightnessMappingStrategy.java](https://android.googlesource.com/platform/frameworks/base/+/refs/tags/android-12.1.0_r11/services/core/java/com/android/server/display/BrightnessMappingStrategy.java).

# Usage

Extract your auto brightness overlays here into each table.

```
% Tables extracted from overlays.
lux = [
];

brightness = [
];

screen_brightness = [
];

screen_backlight = [
];
```

Set the user data point here to emulate a user input.

```
% Ambient light and user brightness you want to input.
% Note that brightness must be normalized to [0f, 1f].
user_lux = 12000;
user_backlight = 0.8;
```

Run it and see the figures.

Basically the last figure ( figure 6 ) is the final auto brightness curve generated from user input. And the other figures are mean to help you understand how each step work.

# Typical result

![p](https://blog.xzr.moe/usr/uploads/2022/07/134922221.png)

![p](https://blog.xzr.moe/usr/uploads/2022/07/276741012.png)

![p](https://blog.xzr.moe/usr/uploads/2022/07/2526422388.png)

![p](https://blog.xzr.moe/usr/uploads/2022/07/2726813334.png)

![p](https://blog.xzr.moe/usr/uploads/2022/07/139978967.png)
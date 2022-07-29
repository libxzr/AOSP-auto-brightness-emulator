global MIN_PERMISSABLE_INCREASE LUX_GRAD_SMOOTHING MAX_GRAD lux brightness screen_brightness screen_backlight;

% Tables extracted from overlays.
lux = [
    0;
    1;
    4;
    12;
    20;
    28;
    47;
    63;
    86;
    150;
    160;
    220;
    270;
    360;
    420;
    510;
    620;
    1000;
    2000;
    3100;
    5000;
    8000;
    12000;
    16000;
    20000;
];

brightness = [
    2.0487;
    4.8394;
    17.2619;
    39.2619;
    50.671;
    72.95;
    80.46;
    84.38;
    89.51;
    100.34;
    102.21;
    109.48;
    114.19;
    123.86;
    129.18;
    138.07;
    145.62;
    168.84;
    234.9;
    280;
    320;
    360;
    405;
    450;
    500;
];

screen_brightness = [
    0.0;
    2.1;
    2.31;
    2.63;
    3.16;
    3.73;
    4.42;
    5.45;
    6.69;
    8.07;
    9.65;
    11.32;
    13.26;
    15.59;
    18.14;
    20.68;
    23.58;
    26.38;
    29.67;
    32.83;
    36.03;
    39.31;
    43.8;
    47.95;
    52.08;
    56.86;
    61.83;
    67.93;
    73.37;
    79.96;
    86.15;
    90.75;
    97.83;
    105.67;
    112.79;
    120.33;
    127.82;
    135.71;
    145.0;
    153.32;
    161.78;
    170.61;
    179.7;
    190.25;
    201.81;
    212.07;
    222.79;
    234.01;
    246.43;
    257.49;
    269.8;
    281.41;
    293.94;
    307.58;
    322.53;
    335.82;
    349.68;
    364.86;
    379.57;
    398.55;
    413.85;
    429.97;
    442.89;
    461.76;
    478.65;
];

screen_backlight = [
    0;
    4;
    8;
    12;
    16;
    20;
    24;
    28;
    32;
    36;
    40;
    44;
    48;
    52;
    56;
    60;
    64;
    68;
    72;
    76;
    80;
    84;
    88;
    92;
    96;
    100;
    104;
    108;
    112;
    116;
    120;
    123;
    127;
    131;
    135;
    139;
    143;
    147;
    151;
    155;
    159;
    163;
    167;
    171;
    175;
    179;
    183;
    187;
    191;
    195;
    199;
    203;
    207;
    211;
    215;
    219;
    223;
    227;
    231;
    235;
    239;
    243;
    246;
    251;
    255;  
];

% Default parameters picked from AOSP.
MIN_PERMISSABLE_INCREASE =  0.004;
LUX_GRAD_SMOOTHING = 0.25;
MAX_GRAD = 1.0;
ADJUSTMENT_MAX_GAMMA = 3.00;

% Ambient light and user brightness you want to input.
% Note that brightness must be normalized to [0f, 1f].
user_lux = 12000;
user_backlight = 0.8;

% First, calculate backlight. Each entry matches the lux table.
backlight = toBacklight(lux);
% Normalize the backlight.
backlight = backlight ./ 255;

% Plot brightness curve and screen feature.
figure(1);
plot(lux, brightness, "-o", LineWidth=1.5);
title("Auto brightness curve");
xlabel("Illuminance (lux)");
ylabel("Luminance (nit)");
figure(2);
plot(screen_backlight ./ 255, screen_brightness, "-o", LineWidth=1.5);
title("Screen feature curve");
xlabel("Normalized screen backlight");
ylabel("Luminance (nit)");
figure(3);
plot(lux, backlight, "-o", LineWidth=1.5);
title("Auto backlight curve");
xlabel("Illuminance (lux)");
ylabel("Normalized screen backlight");

% Gamma correction only. No user data point.
calculated_backlight = spline(lux, backlight, user_lux);
if calculated_backlight >= 0.9 || calculated_backlight <= 0.1
    adjustment = user_backlight - calculated_backlight;
    gamma = ADJUSTMENT_MAX_GAMMA ^ -adjustment;
else
    gamma = log(user_backlight) / log(calculated_backlight);
    adjustment = -log(gamma) / log(ADJUSTMENT_MAX_GAMMA);
end
adjustment = constrain(adjustment, -1, 1);
gamma = constrain(gamma, ADJUSTMENT_MAX_GAMMA ^ -1, ADJUSTMENT_MAX_GAMMA ^ 1);
adjustment

gamma_backlight = backlight .^ gamma;
figure(4);
plot(lux, backlight, "-o", lux, gamma_backlight, "-o", user_lux, user_backlight, "xk", LineWidth=1.5);
legend("Original", "Gamma correction", "User data point");
title("Influence of gamma correction on auto backlight curve");
xlabel("Illuminance (lux)");
ylabel("Normalized screen backlight");

% User data point + smoothing.
[ulux, ubacklight, insp] = insert(lux, backlight, user_lux, user_backlight);
figure(5);
plot(ulux, ubacklight, "-o", LineWidth=1.5);
hold on;
ubacklight = smooth(ulux, ubacklight, insp);
plot(ulux, ubacklight, "-o", user_lux, user_backlight, "xk", LineWidth=1.5);
legend("Before smoothing", "After smoothing", "User data point");
title("Influence of smoothing on auto backlight curve");
xlabel("Illuminance (lux)");
ylabel("Normalized screen backlight");

% Apply gamma correction first and then user data point + smoothing.
% This is the final curve.
ugbacklight = backlight .^ gamma;
[uglux, ugbacklight, insp] = insert(lux, ugbacklight, user_lux, user_backlight);
ugbacklight = smooth(uglux, ugbacklight, insp);
figure(6);
plot(lux, backlight,"o-.", uglux, ugbacklight,"o-.", user_lux, user_backlight, "xk", LineWidth=1.5);
legend("Original", "Adjusted", "User data point");
title("Adjusted auto backlight curve");
xlabel("Illuminance (lux)");
ylabel("Normalized screen backlight");

function ret_backlight = toBacklight(ilux)
    global lux brightness screen_brightness screen_backlight;
    target_brightness = spline(lux, brightness, ilux);
    ret_backlight = spline(screen_brightness, screen_backlight, target_brightness);
end

function [ret_lux, ret_brightness, insp] = insert(lux, backlight, ilux, ibacklight)
    for i = 1 : length(lux) + 1
        if i == length(lux) + 1
            break;
        end
        if lux(i) >= ilux
            break;
        end
    end
    
    insp = i;
    
    if i == length(lux) + 1
        lux(i) = ilux;
        backlight(i) = ibacklight;
    elseif lux(i) == ilux
        backlight(i) = ibacklight;
    else
        lux = [lux(1 : insp - 1); ilux; lux(insp : end);];
        backlight = [backlight(1 : insp - 1); ibacklight; backlight(insp : end);];
    end

    ret_brightness = backlight;
    ret_lux = lux;
end

function ret_backlight = smooth(lux, backlight, idx)
    global MIN_PERMISSABLE_INCREASE;
    prev_lux = lux(idx);
    prev_backlight = backlight(idx);
    for i = idx + 1 : 1 : length(lux)
        cur_lux = lux(i);
        cur_backlight = backlight(i);
        max_backlight = max(prev_backlight * permissibleRatio(cur_lux, prev_lux), prev_backlight + MIN_PERMISSABLE_INCREASE);
        new_backlight = constrain(cur_backlight, prev_backlight, max_backlight);
        if new_backlight == cur_backlight
            break;
        end
        prev_lux = cur_lux;
        prev_backlight = new_backlight;
        backlight(i) = new_backlight;
    end

    prev_lux = lux(idx);
    prev_backlight = backlight(idx);
    for i = idx - 1 : -1 : 1
        cur_lux = lux(i);
        cur_backlight = backlight(i);
        min_backlight = prev_backlight * permissibleRatio(cur_lux, prev_lux);
        new_backlight = constrain(cur_backlight, min_backlight, prev_backlight);
        if new_backlight == cur_backlight
            break;
        end
        prev_lux = cur_lux;
        prev_backlight = new_backlight;
        backlight(i) = new_backlight;
    end

    ret_backlight = backlight;
end

function ret = permissibleRatio(cur, prev)
    global LUX_GRAD_SMOOTHING MAX_GRAD;
    ret = ((cur + LUX_GRAD_SMOOTHING) / (prev + LUX_GRAD_SMOOTHING)) ^ MAX_GRAD;
end

function ret = constrain(i, min, max)
    if i < min
        ret = min;
    elseif i > max
        ret = max;
    else
        ret = i;
    end
end
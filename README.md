# HealthBank

HealthBank is an application that takes a flexible, insight-driven approach to health tracking. Unlike traditional calorie counting apps that reset daily budgets, HealthBank uses **7-day running average budgeting** to provide a more realistic and sustainable approach to nutrition management.

## Calorie Budget & Maintenance Tracking

This document presents the **mathematical specification** of two core systems:

1. Calorie Credit System
2. Maintenance Estimation System

## Symbols & Parameters

| Symbol               | Description                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| $t$                  | Current day index                                                      |
| $C_t$                | Calorie intake on day $t$ (kcal)                                       |
| $B$                  | User’s daily calorie budget (kcal/day)                                 |
| $S_t$                | EWMA‑smoothed intake at day $t$ (kcal)                                 |
| $\alpha$             | EWMA smoothing factor $(0 < \alpha < 1)$                               |
| $N$                  | Regression window length for weight trend (days)                       |
| $W_t$                | Body weight on day $t$ (lbs)                                           |
| $m$                  | Estimated weight‑change rate (lbs/day)                                 |
| $\rho$               | Energy equivalent of weight change $(3500\ \mathrm{kcal}/\mathrm{lb})$ |
| $M_{\mathrm{raw},t}$ | Raw maintenance estimate on day $t$ (kcal/day)                         |

## 1. Calorie Credit System

### 1.1 EWMA Smoothing of Intake

Smooth the intake series to filter day‑to‑day noise while weighting recent days more heavily:

$$
S_t = \alpha\,C_{t-1} + (1 - \alpha)\,S_{t-1},\quad S_0 = C_0.
$$

* **Interpretation**: $S_t$ is the smoothed estimate of intake for day $t$.

### 1.2 Credit Calculation

Compute the difference (error) between the user’s budget and the smoothed intake:

$$
\mathrm{Credit}_t = B - S_t.
$$

* **Interpretation**: Positive $\mathrm{Credit}_t$ = under budget; negative = over budget.

## 2. Maintenance Estimation System

### 2.1 Weight Trend via Linear Regression

Fit a least‑squares line to the last $N$ days of weight to estimate the daily change rate.
Let

* $i = 0,1,\dots,N-1$
* $w_i = W_{t-N+1+i}$

Compute means:

$$
\bar i = \frac{1}{N}\sum_{i=0}^{N-1} i,
\quad
\bar w = \frac{1}{N}\sum_{i=0}^{N-1} w_i.
$$

Slope (weight‑change rate $m$):

$$
 m = \frac{\sum_{i=0}^{N-1}(i - \bar i)(w_i - \bar w)}{\sum_{i=0}^{N-1}(i - \bar i)^2}.
$$

### 2.2 Energy Imbalance

Convert the weight‑change rate into daily calorie imbalance:

$$
\Delta E_t = m \times \rho.
$$

* Positive $\Delta E_t$ indicates net gain (intake > expenditure).

### 2.3 Raw Maintenance Estimate

Subtract the energy imbalance from smoothed intake:

$$
M_{\mathrm{raw},t} = S_t - \Delta E_t.
$$

---

**Minimal Inputs Required**:

* Intake history: $C_{t-1}$ and previous $S_{t-1}$
* Weight history: $\{W_{t-N+1},\dots,W_t\}$
* Constants: $\alpha, B, N, \rho$

This specification defines all intermediate computations using only daily calories and weights, yielding noise‑resistant estimates for calorie credit and maintenance needs.

# Volatility Surface Calibration & Lévy Models Pricing Engine

## Project Overview
This repository contains a comprehensive MATLAB-based quantitative framework for advanced option pricing and volatility modeling. The project bridges the gap between market data and stochastic calculus, focusing on the calibration of Exponential Lévy models and the valuation of structured derivatives using Fourier transform techniques.

*Note: This was a collaborative academic project developed for the Financial Engineering course at Politecnico di Milano. I co-developed the core pricing architecture with my team and took full technical ownership of the Volatility Surface Calibration engine.*

## My Role & Technical Contributions
Our team built the pricing library from the ground up. My specific contributions were split between leading the calibration module and co-developing the broader numerical pricing engines.

### 1. Lead Developer: Volatility Surface Calibration
I designed and implemented the calibration engine to fit a **Normal Tempered Stable (NTS)** model to the EURO STOXX 50 market implied volatility surface.
* **Global Optimization:** Engineered a global calibration routine using unconstrained optimization (`fminsearch`) applied to a penalized Sum of Squared Errors (SSE) loss function.
* **Parameter Admissibility:** Implemented dynamic penalty functions to strictly enforce positivity constraints ($\sigma > 0$, $\kappa > 0$) and the nonlinear admissibility boundary for the skewness parameter ($\eta$).
* **Market Skew Capture:** Successfully calibrated the model to replicate the negative skew of the market, seamlessly integrating the objective function with the adaptive numerical quadrature pricing engine (Lewis formula).

### 2. Co-Developer: Core Pricing Framework
Working alongside my peers, I actively contributed to the mathematical implementation of the following modules:
* **Fourier-Based Option Pricing:** Co-developed the pricing engines for Normal Inverse Gaussian (NIG) and NTS models, solving the Lewis integral via Fast Fourier Transform (FFT), Adaptive Gauss-Kronrod Quadrature, and Analytical Residue Calculus.
* **Structured Products Valuation:** Implemented the pricing logic for an Equity Protection Certificate with an exotic participation coupon (ENI & AXA arithmetic basket) using Moment Matching and Monte Carlo simulations.
* **Smile-Adjusted Digital Options:** Co-authored the finite-difference scheme to compute smile corrections for cash-or-nothing digital calls, correcting the flat-volatility bias of the Black-76 model.

## Key Results
* **Calibration Accuracy:** The calibrated NTS model achieved an excellent fit (SSE $\approx$ 5.82), tightly matching the market implied volatility surface across the entire log-moneyness spectrum.
* **Smile Impact:** Empirical tests showed that neglecting the volatility skew (Black model) systematically underprices ATM digital options by approximately 20% compared to our smile-adjusted approach.
* **Pricing Convergence:** Demonstrated extreme numerical stability, with absolute errors between FFT and Quadrature benchmarking at $\approx 10^{-8}$ for the NIG model.

## Tech Stack
* **Language:** MATLAB
* **Quantitative Methods:** Volatility Surface Calibration, Unconstrained Optimization (Penalty Functions), Fast Fourier Transform (FFT), Numerical Quadrature, Monte Carlo Simulation, Lévy Processes (NIG/NTS).

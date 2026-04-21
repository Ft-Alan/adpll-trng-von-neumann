# ADPLL-Based True Random Number Generator (TRNG)

## Overview

This project models a True Random Number Generator (TRNG) using jitter from an All-Digital Phase Locked Loop (ADPLL) as the entropy source. The raw bitstream exhibits bias and periodicity, which is mitigated using Von Neumann debiasing.

The design focuses on understanding entropy generation and evaluating statistical randomness characteristics through simulation.

---

## Architecture

ADPLL (Entropy Source) → Raw Bitstream → Von Neumann Debiasing → Random Output

---

## Key Features

* Behavioral modeling of ADPLL-based entropy source
* Von Neumann debiasing for bias reduction
* Modular Verilog design (entropy + post-processing separation)
* Statistical evaluation of randomness

---

## Implementation Details

### ADPLL Entropy Source

* Modeled using behavioral constructs to emulate jitter and phase variations
* Generates a raw bitstream with observable bias and periodicity

### Von Neumann Debiasing

* Processes input bits in pairs
* Accepts: `01`, `10`
* Rejects: `00`, `11`
* Reduces bias at the cost of throughput

---

## Randomness Evaluation

The generated bitstream is evaluated using:

* **Transition Probability** (ideal ≈ 0.5)
* **Mean of Output Bits**
* **Lag-1 Autocorrelation**

Evaluation is performed over 2048 samples using a custom Verilog testbench.

---

## Results

* Transition probability improved from ~0.8 to ~0.5 after debiasing
* Significant reduction in bias and correlation
* Throughput reduced to ~25% due to rejection of bit pairs

---

## Simulation

* Simulated using Xilinx Vivado
* Testbench verifies functionality and collects statistical metrics
* Waveforms confirm correct operation of debiasing logic

---

## Note on Implementation

The ADPLL-based entropy source is modeled using real-number delay constructs to emulate jitter behavior.

This implementation is intended for **simulation and statistical analysis only** and is **not synthesizable**.

---

## Key Learnings

* Hardware entropy sources can exhibit deterministic bias
* Post-processing is essential for improving randomness quality
* Trade-off exists between throughput and statistical randomness

---

## Future Work

* Implement synthesizable entropy sources (e.g., ring oscillator-based TRNG)
* Perform NIST randomness testing
* Explore advanced post-processing techniques

---

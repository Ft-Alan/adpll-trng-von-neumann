# ADPLL-Based TRNG with Von Neumann Debiasing

## Problem

Hardware entropy sources often produce biased and partially periodic bitstreams, making them unsuitable for reliable randomness without post-processing.

## Approach

A behavioral ADPLL-based entropy source is modeled to generate a raw bitstream using jitter-like variations.
Von Neumann debiasing is applied to remove bias and improve statistical randomness.

## Architecture

```
ADPLL (Jitter Model)
        ↓
Raw Bitstream (Biased)
        ↓
Von Neumann Debiasing
        ↓
Random Output
```

## Key Results

* Transition probability improved from ~0.8 → ~0.5
* Significant reduction in bias
* Throughput reduced to ~25% due to bit rejection

## Randomness Evaluation

The output bitstream is evaluated using:

* Transition probability (ideal ≈ 0.5)
* Mean of output bits
* Lag-1 autocorrelation

## Key Insight

Improving randomness quality requires sacrificing throughput.
Simple post-processing like Von Neumann can significantly improve statistical properties.

## Note

The entropy source is modeled using behavioral constructs (`real`, delay-based jitter) and is intended for simulation and analysis.
This design is not synthesizable.

## Future Work

* Implement synthesizable entropy sources (e.g., ring oscillator TRNG)
* Perform NIST randomness testing

# System Architecture Document — counter4d · SAD v0.1

> Machine index: `sad.yaml`. Requirements live in `rtm.yaml`, ports in `idd/`, scenarios in
> `vps.yaml`, risk in `riskmap.yaml`, clocks in `clocks.yaml`.

## 1 Scope and context
counter4d is a 4-bit up counter with enable and synchronous reset, on one clock. It sits on an evaluation board (`brs.yaml`). Out of scope: registers, bus interfaces, interrupts, clock domain crossings, power management, memories, clock gating.

Assumptions (all recorded in `decisions.yaml`): the interface is one level-class IDD (ADR-01); the output before the first reset edge is unspecified (ADR-02); the DFT brief is a requirement and scan notes, since the package has no DFT file (ADR-03); no area budget (ADR-04); board rail currents are chosen round values (ADR-05); the 1.8 V LDO and the chip are outside the board standard (ADR-06). The interface is final per the brief.

## 2 Block decomposition
A single block, counter4d, owned by Kemi. No partition is needed for one counter.

## 3.1 Counting behaviour — REQ-3.1.1 … REQ-3.1.6
At each rising edge of clk the block looks at rst_n, then en. Reset has priority (REQ-3.1.1, REQ-3.1.4); with rst_n at 1, en at 1 counts up (REQ-3.1.2) and wraps from 15 to 0 (REQ-3.1.5); en at 0 holds (REQ-3.1.3). The output changes only at a rising edge (REQ-3.1.6).

```
clk   _|‾|_|‾|_|‾|_
en    ‾‾‾‾‾‾‾‾‾‾‾‾‾   (changes at falling edges only)
count  n   n+1  n+2
```

## 3.2 Design for test — REQ-3.2.1
Full scan, one chain, mux-D flops, stuck-at and transition fault models, platform default coverage targets. Scan ports are added by insertion, not by this interface. All flops are scannable (see `scan_notes`).

## 3.3 Physical constraints — REQ-3.3.1
sky130, sky130_fd_sc_hd, flow default utilisation and corners, no macros, no IO ring. Pin sides are in `sad.yaml` pin_intent.

## 3.4 Verification approach — REQ-3.4.1, REQ-3.4.2
Directed tests VPS-01 to VPS-05 cover reset, hold, increment, wrap and reset priority; VPS-06 sweeps for the covergroup. The harness starts clk low, drives inputs only at falling edges, and runs unchanged on the gate-level netlist. A failing regression is reproduced with a single-seed run and fixed before the full batch is run again.

## 6 Performance power and area
Feasibility, on a proxy of the architecture (not RTL), method opensta_liberty (pdk, confidence 0.5), tt corner, 100 MHz target: fmax estimate 1257.9 MHz, worst slack 6.585 ns (path en to a flop), area 140.13 um2, 17 cells; target met. No power or area target is given.

## 7 Risk register
See `riskmap.yaml`.

## 8 Open items
No open ArchChallenge. Board Device Models (chip, 1.8 V LDO) and the parts snapshot come from a person (BRS-9, ADR-06).

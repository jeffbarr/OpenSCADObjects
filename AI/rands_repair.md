Here’s your session converted into a clean Markdown document you can copy or save.

---

# OpenSCAD Random Distribution Debugging Session

## Goal

Generate a uniformly distributed grid of integers (1–4) using OpenSCAD, avoiding statistical bias.

---

## Initial Problem

User generated values using:

```scad
XR = rands(100 * _FirstExtruder, 100 * _LastExtruder, RowCount * ColCount, _RandomSeed);

HexExtruders = 
[
    for (c = [0 : ColCount - 1])
    [
        for (r = [0 : RowCount - 1]) 
            round(XR[r * ColCount + c] / 100)
    ]
];
```

### Result

* Distribution was **not uniform**
* Values **2 and 3 dominated**
* Values **1 and 4 underrepresented**

---

## Root Cause

### Rounding Bias

After scaling and dividing:

```
1.00–4.00 (step 0.01)
```

`round()` creates uneven bins:

| Output | Range     | Width |
| ------ | --------- | ----- |
| 1      | 1.00–1.49 | 0.50  |
| 2      | 1.50–2.49 | 1.00  |
| 3      | 2.50–3.49 | 1.00  |
| 4      | 3.50–4.00 | 0.51  |

➡️ Middle values get **2× probability**

---

## Attempt 2: Using `floor()`

```scad
floor(XR[...] / 100)
```

### Result

* **1 disappeared**
* **4 overrepresented**
* Distribution became **top-heavy**

### Why

* `floor()` compresses range incorrectly
* Upper bound behaves differently due to inclusivity

---

## Correct Approach

### Use uniform continuous distribution → map to integers properly

```scad
XR = rands(0, 1, RowCount * ColCount, _RandomSeed);

HexExtruders =
[
    for (c = [0 : ColCount - 1])
    [
        for (r = [0 : RowCount - 1]) 
            floor(XR[r * ColCount + c] * (_LastExtruder - _FirstExtruder + 1)) + _FirstExtruder
    ]
];
```

---

## Why This Works

For range 1–4:

```
XR ∈ [0,1)
→ XR * 4 ∈ [0,4)
→ floor() ∈ {0,1,2,3}
→ +1 → {1,2,3,4}
```

✔ Equal-width bins
✔ Uniform probability

---

## Final Dataset Analysis

Total values: **960**

### Exact Counts

| Value | Count | Expected | Deviation |
| ----- | ----- | -------- | --------- |
| 1     | 236   | 240      | -4        |
| 2     | 247   | 240      | +7        |
| 3     | 241   | 240      | +1        |
| 4     | 236   | 240      | -4        |

---

## Interpretation

* Max deviation: **7 (~2.9%)**
* No systematic bias
* Symmetric distribution
* Matches expected statistical variation

✔ **Uniform distribution achieved**

---

## Key Lessons

### ❌ Avoid

* `round()` → center bias
* naive `floor()` → edge bias
* scaling like `100–400` → uneven binning

### ✅ Use

* Continuous uniform `[0,1)`
* Multiply by range
* `floor() + offset`

---

## Final Recommendation

For uniform integers in OpenSCAD:

```scad
floor(rands(0, 1, n, seed)[i] * (max - min + 1)) + min
```

---

## Notes for Advanced Use (Puzzle / Security)

* Output is **deterministic from seed**
* Reverse-engineering possible if method is known
* For stronger protection:

  * Mix or hash seed
  * Add transformation layer
  * Consider cryptographic preprocessing

---

## Conclusion

* Initial bias was caused by **incorrect discretization**
* Proper binning fixed the issue
* Final result is **statistically sound and uniform**

---

If you want, I can extend this into:

* a reusable OpenSCAD library
* statistical test harness
* or a “puzzle-hardened” generator design

Just say the word 👍

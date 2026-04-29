# Code for reading Salae oscilloscope binary dumps of analog data

This directory contains the `sally` package which makes it easier to
process analog data from a Salae oscilloscope.

The basic function for this is `readWave`. Because Salae scopes output
one file per channel in a binary dump, it is common to call `readWave`
as in the following example:

```julia
julia> using sally, Glob
readWave(glob(glob"../../../test_sig_analog_?.bin")...)
2-element Vector{Any}:
 sally.WaveForm(-0.0886795229756494, 0.0, 4.0e8, 1, 12598238, Float32[1.5129888, 1.4858569, 1.4817595, 1.4603738, 1.4974492, 1.4701173, 1.5102407, 1.4819095, 1.4749141, 1.4610733  …  1.4993479, 1.4710667, 1.4882553, 1.4654204, 1.4882053, 1.4559767, 1.502196, 1.4730654, 1.4871559, 1.4626722])
 sally.WaveForm(-0.0886795229756494, 0.0, 4.0e8, 1, 12598238, Float32[3.2809725, 3.291279, 3.2933857, 3.3046703, 3.2890725, 3.295768, 3.2798693, 3.2944891, 3.2962444, 3.3056483  …  3.298777, 3.2820508, 3.290577, 3.293135, 3.304244, 3.2972724, 3.297072, 3.2814991, 3.2914045, 3.2954168])
julia>
```
The result of this is a vector of waveform structures, one for each
filename argument.

In addition to support for reading waveforms, there is basic support
for computing power spectra and estimating the power at particular
frequencies. As an example, we can recover the magnitude of a sine
wave of known frequency deeply embedded in noise:

```julia
julia> using sally
julia> s500 = sin.(LinRange(0, 2π * 500, 100_000));
julia> s600 = sin.(LinRange(0, 2π * 600, 100_000));
julia> signal = sally.WaveForm(0, 0, 1e5, 1, 100_000, s500 + 2 * s600 + 10.0 * randn(100_000));
julia> findPeaks(s, 490:5:510)
5-element Vector{Float32}:
 64.842316
 72.46116
 88.28233
 57.876255
 67.415985
julia> findPeaks(s, 590:5:610)
5-element Vector{Float32}:
 68.96326
 65.275764
 93.94074
 67.35667
 70.97655
 ```

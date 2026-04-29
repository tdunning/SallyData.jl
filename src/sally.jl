module sally

# read analog data from a Salae oscilloscope binary dump

export Spectrum, spectrum, findPeaks, readWave
using FFTW

struct Header
    identifier::String
    version::Int32            # version 1
    type::Int32               # 1 for Analog
    waveforms::UInt64;        # Number of waveforms
end                           
                              
struct WaveForm               
    begin_time::Float64       # Start time in seconds
    trigger_time::Float64     # Trigger time in seconds
    sample_rate::Float64      # Samples per second
    downsample::Int64         # Downsample factor
    num_samples::Int64        # Number of voltage samples
    samples::Vector{Float32}  # The actual data
end

struct Spectrum
    sample_rate::Float64      # the sample rate of the original data
    num_samples::Int64        # the number of samples that were processed
    Δf::Float64               # the change frequency between elements of sp
    sp::Vector{Float32}       # the power spectrum in dB
end

"""
Computes the power spectrum (expressed in dB) of a trace up to and
including a cutoff frequency f_c using Hann windowing.
"""
function spectrum(trace, fc)::Spectrum
    w = sin.(LinRange(0, π, trace.num_samples)).^2
    sp = 20 * log10.(abs.(fft(w .* trace.samples) ./ (trace.num_samples/2)))
    Δf = trace.sample_rate/trace.num_samples
    Spectrum(trace.sample_rate, trace.num_samples, Δf, sp[1:Int(ceil(fc/Δf + 1))])
end

"""
Computes the power in the given spectrum near a particular frequency. 
"""
function findPeaks(spectrum::Spectrum, freq::Number)
    i = freq/spectrum.Δf
    maximum(spectrum.sp[Int(floor(i-1)):Int(ceil(i+1))])
end

"""
Computes the power in the given spectrum near each of multiple frequencies
"""
function findPeaks(spectrum::Spectrum, frequencies::AbstractArray)
    findPeaks.(Ref(spectrum), frequencies)
end

"""
Finds the power in the given spectrum near each of the first n harmonics of a particular
frequency.
""" 

function findPeaks(spectrum::Spectrum, freq, n)
    findPeaks(spectrum, (1:n) .* freq)
end

"""
Reads waveforms from a number of binary files containing analog waveforms recorded by a
Salae oscilloscope. Commonly used with glob to read all of the data in files from
different channels.
"""
function readWave(fx...)
    r = []
    for fn in fx
        open(fn) do f
            h = readHeader(f)
            for i in 1:h.waveforms
                push!(r, readSingleWaveForm(f))
            end
        end
    end
    return r
end


function readHeader(f)::Header
    id = zeros(UInt8, 8)
    read!(f, id)
    sid = String(id)
    if sid != "<SALEAE>"
        throw(ArgumentError("File has invalid magic string ($sid)"))
    end
    version = read(f, Int32)
    type = read(f, Int32)
    waveforms = read(f, UInt64)

    
    if version != 1 || type != 1
        throw(ArgumentError("File has invalid version or type ($version, $type)"))
    end
    return Header(sid, version, type, waveforms)
end

function readSingleWaveForm(f)::WaveForm
    begin_time = read(f, Float64)
    trigger_time = read(f, Float64)
    sample_rate = read(f, Float64)
    downsample = read(f, Int64)
    num_samples = read(f, UInt64)

    if sample_rate ≤ 0
        throw(ArgumentError("Invalid sample rate ($sample_rate)"))
    end
    if downsample ≤ 0
        throw(ArgumentError("Invalid downsample ($sample_rate)"))
    end
    if num_samples ≤ 0 || num_samples > 10^9
        throw(ArgumentError("Invalid number of samples ($num_samples)"))
    end

    samples = zeros(Float32, num_samples)
    read!(f, samples)

    return WaveForm(begin_time, trigger_time, sample_rate, downsample, num_samples, samples)
end


end # module sally

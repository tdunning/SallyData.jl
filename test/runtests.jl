using Test

using SallyScope
let s = readWave("./test_analog_0.bin")
    @test s[1].num_samples == 382

    @test s[1].sample_rate == 1.6e9

    @test s[1].begin_time ≈ -0.05786 atol=1e-5

    @test s[1].trigger_time == 0.0

    @test s[1].downsample == 1

    @test s[1].samples[1:5] ≈ [0.80870533, 0.79129165, 0.7982571, 0.8206461, 0.8400499]
end

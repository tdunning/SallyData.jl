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

let s = readCSV("./t1.csv", "v", sampleRate=1e6)
    @test s.num_samples == 10
    @info s
end

let s = readCSV("./t2.csv", "v", time="t")
    @test s.num_samples == 10
    @info s
end

@test_throws ErrorException readCSV("./t3.csv", "v", time="t")

@test_throws ErrorException readCSV("./t2.csv", "v")

@test_throws ErrorException readCSV("./t2.csv", "q")

let s = readCSV("./t4.csv", "v", sampleRate=1000)
    let dx = downsample(s, 30)
        @test dx.num_samples == 33
        @test minimum(dx.samples) > 0.97
    end
    let dx = downsample(s, 30; f=x->minimum(abs.(x)))
        @test dx.num_samples == 33
        @test maximum(dx.samples) < 0.2
    end
    let dx = downsample(s, 60; f=x->minimum(x .* x))
        @test dx.num_samples == 16
        @test maximum(dx.samples) < 0.03
    end
end

    

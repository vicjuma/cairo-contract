```cairo
let policy_data : (u256, u256, u64, u64, u256, u256) = match risk_type {
                RiskType::HighWindsAndCyclones => {
                    // Wind speed > 120 km/h
                    // 500 tokens per hectare affected
                    // 2% of insured amount
                    // Max coverage of 10,000 tokens
                    (120, 500, 1672531200, 1704067200, 2, 10000) // -> (trigger_threshold, payout_per_hectare, coverage_period_start, coverage_period_end, premium_percentage, max_coverage)
                },
                RiskType::ExtremeTemperature => {
                    // Temperature > 45°C
                    // 700 tokens per hectare
                    // 3% of insured amount
                    // Max coverage of 20,000 tokens
                    (45, 700, 1672531200, 1704067200, 3, 20000)
                },
                RiskType::Hailstorms => {
                    // Hail size > 1 cm
                    // 800 tokens per hectare
                    // 1% of insured amount
                    // Max coverage of 15,000 tokens
                    (1, 800, 1672531200, 1704067200, 1, 15000)
                },
                RiskType::Flooding => {
                    // Rainfall > 200 mm in 24 hours
                    // 1000 tokens per hectare
                    // 4% of insured amount
                    // Max coverage of 25,000 tokens
                    (200, 1000, 1672531200, 1704067200, 4, 25000)
                },
                RiskType::Drought => {
                    // Rainfall < 30 mm in 30 days
                    // 600 tokens per hectare
                    // 1% of insured amount
                    // Max coverage of 15,000 tokens
                    (30, 600, 1672531200, 1704067200, 2, 12000) 
                },
                RiskType::None => {
                    (120, 500, 1672531200, 1704067200, 2, 1000)
                },
            };
```
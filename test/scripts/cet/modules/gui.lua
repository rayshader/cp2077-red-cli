local function Draw(data)
    if ImGui.Begin('Window') then
        ImGui.Text('Hello world :)')
        ImGui.Text('Counter: ' .. tostring(data.counter))
        ImGui.End()
    end
end

return {
    Draw = Draw
}

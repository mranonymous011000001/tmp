$b = Get-CimInstance Win32_Battery

[PSCustomObject]@{
    ChargePercent   = "$($b.EstimatedChargeRemaining)%"
    Status          = switch ($b.BatteryStatus) {
        1 {"Discharging"}
        2 {"Charging"}
        3 {"Fully Charged"}
        4 {"Low"}
        5 {"Critical"}
        default {"Unknown"}
    }
    RuntimeMinutes  = $b.EstimatedRunTime
    Voltage         = "$($b.DesignVoltage) mV"
    DeviceID        = $b.DeviceID
}

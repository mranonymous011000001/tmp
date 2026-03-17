$b1 = Get-CimInstance Win32_Battery
$b2 = Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus
$b3 = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData

[PSCustomObject]@{
    ChargePercent   = "$($b1.EstimatedChargeRemaining)%"
    Status          = switch ($b1.BatteryStatus) {
        1 {"Discharging"}
        2 {"Charging"}
        3 {"Fully Charged"}
        default {"Unknown"}
    }

    PluggedIn       = $b2.PowerOnline
    ChargingFlag    = $b2.Charging
    DischargingFlag = $b2.Discharging

    Remaining_mWh   = $b2.RemainingCapacity
    Voltage_mV      = $b2.Voltage
    Rate_mW         = $b2.Rate

    DesignCapacity  = $b3.DesignedCapacity
    Chemistry       = $b3.Chemistry
}

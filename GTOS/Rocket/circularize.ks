function executeManeuver {
    parameter utime, radial, normal, prograde.
    local mnv is node(utime, radial, normal, prograde).
    addManeuverToFlightPlan(mnv).
    wait until time:seconds > startTime -10.
    lockSteeringAtManeuverTarget(mnv).
    wait until time:seconds > startTime. 
    lock throttle to 1.
    wait until isManeuverComplete(mnv).
    lock throttle to 0.
    cleanUpManeuver(mnv).
}.

function addManeuverToFlightPlan {
    parameter mnv.
    add mnv .
}

function calculateStartTime {
    parameter mnv.
    set CurrentTime to time:seconds.
    set BurnTime to 10. //PLACEHOLDER
    set StartTime to currentTime + mnv:eta - BurnTime/2.
    return StartTime.
}

function lockSteeringAtManeuverTarget {
    parameter mnv.
    lock steering to mnv:burnvector:direction.
}

function isManeuverComplete{
    parameter mnv.
    if (not defined originalVector) or originalVector = -1{
        global originalVector to mnv:burnvector.
    }
    lock VectorChange to vang(originalVector, mnv:burnvector).
    if VectorChange > 90{
        global originalVector to -1.
        // Delete original Vector
        return true.
    }
    return false.
}

function cleanUpManeuver{
    parameter mnv.
    unlock steering.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    unlock throttle.
    remove mnv.
}
 
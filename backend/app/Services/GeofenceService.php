<?php

namespace App\Services;

class GeofenceService
{
    /**
     * Calculate distance between two geographic coordinates using Haversine formula
     * 
     * @param float $lat1 User latitude
     * @param float $lon1 User longitude
     * @param float $lat2 Project latitude
     * @param float $lon2 Project longitude
     * @return float Distance in meters
     */
    public function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // Earth radius in meters

        $lat1Rad = deg2rad($lat1);
        $lat2Rad = deg2rad($lat2);
        $deltaLat = deg2rad($lat2 - $lat1);
        $deltaLon = deg2rad($lon2 - $lon1);

        $a = sin($deltaLat / 2) * sin($deltaLat / 2) +
            cos($lat1Rad) * cos($lat2Rad) * sin($deltaLon / 2) * sin($deltaLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c; // Distance in meters
    }

    /**
     * Check if a location is within geofence
     * 
     * @param float $userLat User latitude
     * @param float $userLon User longitude
     * @param float $projectLat Project latitude
     * @param float $projectLon Project longitude
     * @param int $radiusMeters Geofence radius in meters
     * @return array ['is_within' => bool, 'distance' => float]
     */
    public function isWithinGeofence($userLat, $userLon, $projectLat, $projectLon, $radiusMeters = 100)
    {
        $distance = $this->calculateDistance($userLat, $userLon, $projectLat, $projectLon);
        
        return [
            'is_within' => $distance <= $radiusMeters,
            'distance' => round($distance, 2)
        ];
    }
}

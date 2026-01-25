<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    public $timestamps = false;
    protected $table = 'attendance';

    protected $fillable = [
        'user_id',
        'project_id',
        'date',
        'check_in',
        'check_out',
        'marked_latitude',
        'marked_longitude',
        'distance_from_geofence',
        'is_within_geofence',
        'is_verified',
        'face_image_path',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'check_in' => 'datetime',
            'check_out' => 'datetime',
            'marked_latitude' => 'decimal:8',
            'marked_longitude' => 'decimal:8',
            'distance_from_geofence' => 'integer',
            'is_within_geofence' => 'boolean',
            'is_verified' => 'boolean',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }
}

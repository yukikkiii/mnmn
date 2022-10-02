<?php

namespace App\Models;

use Grimzy\LaravelMysqlSpatial\Eloquent\SpatialTrait;
use Illuminate\Database\Eloquent\Model;

class PraySite extends Model
{
    use SpatialTrait;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'is_paid',
        'name',
        'point',
        'pr',
        'prefecture_id',
        'views',
    ];

    protected $hidden = [
        'is_paid',
        'created_at',
        'updated_at',
        'prefecture_id',
        'radius',
        'views',
    ];

    protected $spatialFields = [
        'point',
    ];

    public function prefecture()
    {
        return $this->belongsTo(Prefecture::class);
    }
}

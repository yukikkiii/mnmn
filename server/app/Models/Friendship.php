<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Friendship extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'from',
        'to',
    ];

    protected $hidden = [
        'from',
    ];

    public function user()
    {
        return $this->hasOne(User::class, 'id', 'to');
    }
}

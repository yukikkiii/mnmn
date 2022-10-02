<?php

namespace App\Nova;

use App\Models\Prefecture;
use GeneaLabs\NovaMapMarkerField\MapMarker;
use Illuminate\Http\Request;
use Laravel\Nova\Fields\Boolean;
use Laravel\Nova\Fields\DateTime;
use Laravel\Nova\Fields\Gravatar;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\Number;
use Laravel\Nova\Fields\Password;
use Laravel\Nova\Fields\Select;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;

class PraySite extends Resource
{
    /**
     * The model the resource corresponds to.
     *
     * @var string
     */
    public static $model = \App\Models\PraySite::class;

    /**
     * The logical group associated with the resource.
     *
     * @var string
     */
    public static $group = 'イノリドコロ';

    /**
     * The single value that should be used to represent the resource when being displayed.
     *
     * @var string
     */
    public static $title = 'name';

    /**
     * The columns that should be searched.
     *
     * @var array
     */
    public static $search = [
        'name',
    ];

    /**
     * Get the displayable label of the resource.
     *
     * @return string
     */
    public static function label()
    {
        return 'イノリドコロ';
    }

    /**
     * Get the fields displayed by the resource.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function fields(Request $request)
    {
        return [
            ID::make(__('ID'), 'id')->sortable(),

            Text::make('名前', 'name')
                ->required()
                ->rules('required')
                ->sortable(),

            Select::make('都道府県', 'prefecture_id')
                ->required()
                ->options(function () {
                    return Prefecture::all()
                        ->pluck('name', 'id');
                })
                ->displayUsingLabels()
                ->sortable(),

            MapMarker::make('座標')
                ->defaultLatitude(35.658584)
                ->defaultLongitude(139.7454316)
                ->fieldType('point')
                ->pointField('point'),

            Textarea::make('PR文', 'pr')
                ->sortable(),

            Boolean::make('有料', 'is_paid')
                ->sortable(),

            // Number::make('PV数', 'views')
            //     ->hideWhenCreating()
            //     ->hideWhenUpdating()
            //     ->sortable(),

            DateTime::make('登録日時', 'created_at')
                ->hideWhenCreating()
                ->hideWhenUpdating()
                ->sortable(),
        ];
    }

    /**
     * Get the cards available for the request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function cards(Request $request)
    {
        return [];
    }

    /**
     * Get the filters available for the resource.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function filters(Request $request)
    {
        return [];
    }

    /**
     * Get the lenses available for the resource.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function lenses(Request $request)
    {
        return [];
    }

    /**
     * Get the actions available for the resource.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function actions(Request $request)
    {
        return [];
    }

    public static function indexQuery(NovaRequest $request, $query)
    {
        $search = $request->input('search');
        if (empty($search)) {
            return $query;
        }

        return $query->orWhereHas(
            'prefecture',
            fn ($query) => $query->where('name', '=', $search),
        );
    }
}

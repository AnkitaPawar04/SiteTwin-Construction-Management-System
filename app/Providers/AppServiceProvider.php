<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Gate;
use App\Models\Project;
use App\Models\Task;
use App\Models\DailyProgressReport;
use App\Models\MaterialRequest;
use App\Models\Attendance;
use App\Policies\ProjectPolicy;
use App\Policies\TaskPolicy;
use App\Policies\DailyProgressReportPolicy;
use App\Policies\MaterialRequestPolicy;
use App\Policies\AttendancePolicy;

class AppServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Project::class => ProjectPolicy::class,
        Task::class => TaskPolicy::class,
        DailyProgressReport::class => DailyProgressReportPolicy::class,
        MaterialRequest::class => MaterialRequestPolicy::class,
        Attendance::class => AttendancePolicy::class,
    ];

    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Register policies
        foreach ($this->policies as $model => $policy) {
            Gate::policy($model, $policy);
        }
    }
}


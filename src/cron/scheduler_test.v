module cron

import time

fn test_scheduler_add_job() {
	mut fired_jobs := []Job{}
	callback := fn [mut fired_jobs] (job Job) {
		fired_jobs << job
	}

	mut scheduler := new_scheduler(callback)

	job_id := scheduler.add('test-job', 'Test message', 100 * time.millisecond, 'channel1',
		'chat1')

	assert job_id != ''

	jobs := scheduler.list()
	assert jobs.len == 1
	assert jobs[0].name == 'test-job'
	assert jobs[0].message == 'Test message'
	assert jobs[0].recurring == false
}

fn test_scheduler_add_recurring_job() {
	mut fired_jobs := []Job{}
	callback := fn [mut fired_jobs] (job Job) {
		fired_jobs << job
	}

	mut scheduler := new_scheduler(callback)

	job_id := scheduler.add_recurring('recurring-job', 'Recurring message', 50 * time.millisecond,
		'channel1', 'chat1')

	assert job_id != ''

	jobs := scheduler.list()
	assert jobs.len == 1
	assert jobs[0].name == 'recurring-job'
	assert jobs[0].recurring == true
	assert jobs[0].interval == 50 * time.millisecond
}

fn test_scheduler_list_empty() {
	callback := fn (job Job) {}
	mut scheduler := new_scheduler(callback)

	jobs := scheduler.list()
	assert jobs.len == 0
}

fn test_scheduler_list_with_jobs() {
	mut fired_jobs := []Job{}
	callback := fn [mut fired_jobs] (job Job) {
		fired_jobs << job
	}

	mut scheduler := new_scheduler(callback)

	scheduler.add('job1', 'Message 1', 100 * time.millisecond, 'channel1', 'chat1')
	scheduler.add('job2', 'Message 2', 200 * time.millisecond, 'channel2', 'chat2')

	jobs := scheduler.list()
	assert jobs.len == 2
	has_job1 := jobs.any(|job| job.name == 'job1')
	has_job2 := jobs.any(|job| job.name == 'job2')
	assert has_job1 == true
	assert has_job2 == true
}

fn test_scheduler_cancel_by_name() {
	mut fired_jobs := []Job{}
	callback := fn [mut fired_jobs] (job Job) {
		fired_jobs << job
	}

	mut scheduler := new_scheduler(callback)

	scheduler.add('cancel-test', 'To be cancelled', 100 * time.millisecond, 'channel1',
		'chat1')

	cancelled := scheduler.cancel_by_name('cancel-test')
	assert cancelled == true

	jobs := scheduler.list()
	has_cancel := jobs.any(|job| job.name == 'cancel-test')
	assert has_cancel == false
}

fn test_scheduler_cancel_nonexistent() {
	callback := fn (job Job) {}
	mut scheduler := new_scheduler(callback)

	cancelled := scheduler.cancel_by_name('nonexistent')
	assert cancelled == false
}

// fn test_scheduler_job_firing() {
//     mut fired_jobs := []Job{}
//     callback := fn [mut fired_jobs] (job Job) {
//         fired_jobs << job
//     }
//
//     mut scheduler := new_scheduler(callback)
//
//     scheduler.add('fire-test', 'Should fire quickly', 10 * time.millisecond, 'channel1',
//         'chat1')
//
//     spawn scheduler.start()
//
//     time.sleep(200 * time.millisecond)
//
//     scheduler.stop()
//
//     assert fired_jobs.len == 1
//     assert fired_jobs[0].name == 'fire-test'
//     assert fired_jobs[0].message == 'Should fire quickly'
// }

SELECT * FROM treatments;

SELECT * FROM patient;

--1. How many patient are registered in the hospital system
SELECT 
	COUNT(DISTINCT patient_id) AS 
	total_patient FROM patient;

--2. How many hospital appointments have been recorded
 SELECT
	COUNT(appointment_id) AS 
	Total_appointment 
	FROM appointments;

--3. What is the total revenue generated from treatments and healthcare services.
SELECT
	SUM(treatment_cost) AS total_revenue
	FROM treatments;

--4. What is the average cost of treatments provided to patients
SELECT 
	AVG(treatment_cost) as avg_treatment_cost
	FROM treatments;

--5. Which hosiptal department records the highest patient activity
SELECT
	d.department_name,
	COUNT(a.appointment_id) AS total_appointments
	FROM appointments a
	JOIN doctors doc
	ON a.doctor_id = doc.doctor_id
	JOIN department d
	ON d.department_id = doc.department_id
GROUP BY d.department_name
ORDER BY total_appointments;

--6. Which age group visits the hospital most frequently
SELECT 
	CASE WHEN age BETWEEN 1 AND 12 THEN '1 - 12, child'
		WHEN age BETWEEN 13 AND 19 THEN '13 - 19, teenager'
		WHEN age BETWEEN 20 AND 35 THEN '20 - 35, young adult'
		WHEN age BETWEEN 36 AND 59 THEN '36 - 59, adult'
		ELSE '60 above, elder'
		END AS age_group,
	COUNT(patient_id) AS total_patients
	FROM patient
	GROUP BY 
		CASE WHEN age BETWEEN 1 AND 12 THEN '1 - 12, child'
			WHEN age BETWEEN 13 AND 19 THEN '13 - 19, teenager'
			WHEN age BETWEEN 20 AND 35 THEN '20 - 35, young adult'
			WHEN age BETWEEN 36 AND 59 THEN '36 - 59, adult'
			ELSE '60 above, elder'
			END
		ORDER BY total_patients DESC;

--7. Which gender has the highest number of hospital visits
	SELECT 
		gender,
	COUNT(patient_id) AS total_visit
	FROM patient
	GROUP BY gender;

--8. Which cities contribute the highest number of patients
SELECT 
	city,
	COUNT(patient_id) AS patient_per_city
	FROM patient
	GROUP BY city
	ORDER BY patient_per_city;

--9. Which diagnoses are most commom among patients
SELECT 
	diagnosis,
	COUNT(patient_id) AS common_diagnoses
	FROM patient
	GROUP BY diagnosis
	ORDER BY common_diagnoses DESC;


--10. Which month records the highest number of appointment
SELECT 
	DATENAME(MONTH, appointment_date) 
	AS month_name,
	COUNT(appointment_id) AS total_appointment
	FROM appointments
	GROUP BY 
		DATENAME(MONTH, appointment_date),
		MONTH(appointment_date)
	ORDER BY total_appointment DESC;


--11. Which days or period expericence peak hospital traffic
SELECT 
	DATENAME(WEEKDAY, appointment_date) 
	AS month_name,
	COUNT(appointment_id) AS total_appointment
	FROM appointments
	GROUP BY 
		DATENAME(WEEKDAY, appointment_date),
		DATEPART(WEEKDAY,appointment_date)
	ORDER BY total_appointment DESC;

--12. Which department record the highest appointment volume
SELECT
	d.department_name,
	COUNT(a.appointment_id) AS total_appointments
	FROM appointments a
	JOIN doctors doc
	ON a.doctor_id = doc.doctor_id
	JOIN department d
	ON d.department_id = doc.department_id
GROUP BY d.department_name
ORDER BY total_appointments;

---Which department haas highest patient load

--13. Which doctors handle the highest number of patient
SELECT TOP 10
	doc.doctor_name,
	COUNT(a.appointment_id) AS total_appointments
	FROM appointments a
	JOIN doctors doc
	ON a.doctor_id = doc.doctor_id
	JOIN department d
	ON d.department_id = doc.department_id
GROUP BY doc.doctor_name
ORDER BY total_appointments DESC;

--14. Which doctor generate the highest treatment revenue
SELECT TOP 10
	doc.doctor_name,
	SUM(t.treatment_cost) AS totat_revenue
	FROM treatments t
	JOIN doctors doc
	ON t.doctor_id = doc.doctor_id
	GROUP BY doc.doctor_name;

--15. Which department contributes the highest revenue
SELECT
	d.department_name,
	SUM(t.treatment_cost) AS total_revenue
	FROM treatments t
	JOIN doctors doc
	ON t.doctor_id = doc.doctor_id
	JOIN department d
	ON d.department_id = doc.department_id
GROUP BY d.department_name
ORDER BY total_revenue

--16. Which p  ayment method is most frequent used by patient
SELECT 
	b.payment_method,
	COUNT(bill_id) AS total_billing
	FROM billing b
	GROUP BY b.payment_method
	ORDER BY total_billing;

--17. How does hospital revenue trend over time
--18. Which treatments are most frequently administered
WITH treatment_cte AS 
(
	SELECT 
		treatment_type,
		COUNT(*) AS total_administered
	FROM treatments
	GROUP BY treatment_type
)
SELECT * 
FROM treatment_cte
ORDER BY total_administered DESC;

--19. Which diagnoses result in the highest treatment costs
SELECT 
	diagnosis,
	SUM(treatment_cost) AS total_treatment_cost
	FROM treatments t
	JOIN patient p
			ON t.patient_id = p.patient_id
		GROUP BY diagnosis
		ORDER BY total_treatment_cost

--20. Are certain diseaes more commom among specific age group
SELECT 
	CASE WHEN age BETWEEN 1 AND 12 THEN '1 - 12, child'
		WHEN age BETWEEN 13 AND 19 THEN '13 - 19, teenager'
		WHEN age BETWEEN 20 AND 35 THEN '20 - 35, young adult'
		WHEN age BETWEEN 36 AND 59 THEN '36 - 59, adult'
		ELSE '60 above, elder'
		END AS age_group,
		diagnosis,
	COUNT(patient_id) AS total_case
	FROM patient
	GROUP BY 
		CASE WHEN age BETWEEN 1 AND 12 THEN '1 - 12, child'
			WHEN age BETWEEN 13 AND 19 THEN '13 - 19, teenager'
			WHEN age BETWEEN 20 AND 35 THEN '20 - 35, young adult'
			WHEN age BETWEEN 36 AND 59 THEN '36 - 59, adult'
			ELSE '60 above, elder'
			END,
			diagnosis
		ORDER BY age_group, total_case DESC;

--21. Which treatment types generate the highest revenue.
SELECT 
	treatment_type,
	SUM(treatment_cost) AS total_revenue
	FROM treatments
	GROUP BY treatment_type
	ORDER BY total_revenue;


--22. Which patients are likely to require repeated hospital visist
WITH patient_visits AS (
	SELECT 
		p.patient_id,
		p.first_name,
		p.gender,
		p.age,
		p.diagnosis,
		COUNT(a.appointment_id) OVER (PARTITION BY p.patient_id)
		AS total_visits
	FROM patient p
	JOIN appointments a
		ON p.patient_id = a.patient_id
)
SELECT DISTINCT 
	patient_id,
	first_name,
	gender,
	age,
	total_visits,
RANK() OVER (
	ORDER BY total_visits DESC
	) AS visit_rank
FROM patient_visits
ORDER BY total_visits DESC;

--23. Which departments experience the highest operational pressure
SELECT 
	d.department_name,
	COUNT(a.appointment_id) AS total_appointments,
	COUNT(DISTINCT a.patient_id) AS total_patient,
	COUNT(DISTINCT doc.doctor_id) AS total_doctors,
	ROUND(
		COUNT(appointment_id) * 1.0/
		COUNT(DISTINCT doc.doctor_id), 2
	) AS workload_per_doctor
FROM appointments a
JOIN doctors doc
	ON a.doctor_id = doc.doctor_id
JOIN department d
	ON doc.department_id = d.department_id
GROUP BY d.department_name
ORDER BY workload_per_doctor DESC;

--24-Is there a relationship between appointment status and department workload
SELECT 
	d.department_name,
	a.status,
	COUNT(a.appointment_id) AS total_appointments,
	ROUND(
	COUNT(a.appointment_id) * 100.0/
	SUM(COUNT(a.appointment_id)) OVER 
	(PARTITI ON BY d.department_name), 2
) AS percentage_by_department
	FROM appointments a
	JOIN doctors doc
	ON a.doctor_id = doc.doctor_id
JOIN department d
	ON doc.department_id = d.department_id
GROUP BY 
	d.department_name,
	a.status
ORDER BY 
	d.department_name

--25. Which doctors demostrate the highest operational efficiency
SELECT 
	d.doctor_name,
	COUNT(a.appointment_id) AS total_appointments,
	COUNT(CASE
			WHEN a.status = 'completed' THEN 1
			END) AS completed_appointments,
	COUNT(CASE
			WHEN a.status = 'cancelled' THEN 1
			END) AS cancelled_appointments,
	ROUND(
		COUNT(CASE
			WHEN a.status = 'completed' THEN 1
			END) * 100.0 / COUNT(a.appointment_id), 2
		) AS completion_rate 
	FROM appointments a 
	JOIN doctors d 
		ON a.doctor_id = d.doctor_id
	GROUP BY d.doctor_name
	ORDER BY completion_rate DESC, 
			total_appointments DESC;

--26. What treads can be observed in healthcare service demand over time
SELECT 
	YEAR(appointment_date) AS appointment_year,
	MONTH(appointment_date) AS appointment_month,
	COUNT(appointment_id) AS total_appointment,
	COUNT(DISTINCT patient_id) AS total_patients
	FROM appointments
	GROUP BY 
		YEAR(appointment_date),
		MONTH(appointment_date)
	ORDER BY 
		appointment_year,
		appointment_month;

--KPI Appointment Completion
SELECT 
	ROUND(
		COUNT(CASE
		WHEN status = 'Completed'  THEN 1
		END) * 100.0/ COUNT(*), 2
	) AS completion_rate
	FROM appointments;

--TOP DOCTOR BY PRODUCT VOLUME
SELECT TOP 1
	doc.doctor_name,
	COUNT(a.patient_id) AS total_patients
	FROM appointments a
	JOIN doctors doc 
	ON a.doctor_id = doc.doctor_id
GROUP BY doc.doctor_name
ORDER BY total_patients DESC;

--KPI Appointment Cancelled rate
SELECT 
	ROUND(
		COUNT(CASE
		WHEN status = 'Cancelled'  THEN 1
		END) * 100.0/ COUNT(*), 2
	) AS cancelled_rate
	FROM appointments;

---KPI Appointment pending rate
	SELECT 
	ROUND(
		COUNT(CASE
		WHEN status = 'pending'  THEN 1
		END) * 100.0/ COUNT(*), 2
	) AS pending_rate
	FROM appointments;
	
--KPI TOP Department by Appointment
SELECT TOP 1
	d.department_name,
	COUNT(a.appointment_id) AS total_appointments
	FROM appointments a
JOIN doctors doc
	ON a.doctor_id = doc.doctor_id
JOIN department d
	ON doc.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_appointments DESC;

--KPI Highest revenue department
	SELECT TOP 1
	d.department_name,
	SUM(t.treatment_cost) AS total_revenue
	FROM treatments t
JOIN doctors doc
	ON t.doctor_id = doc.doctor_id
JOIN department d
	ON doc.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_revenue DESC;


--KPI Operational workload per Doctor
SELECT 
	ROUND(
		COUNT(appointment_id) * 1.0 /
		COUNT(DISTINCT doctor_id), 2
	) AS workload_per_doctor
	FROM appointments;


--Which doctors handle the highest patients
SELECT 
	doc.doctor_id,
	doc.doctor_name,
	COUNT(a.patient_id) AS total_patient_handled
FROM doctors doc
JOIN appointments a
	ON doc.doctor_id = a.doctor_id
	GROUP BY 
		doc.doctor_id,
		doc.doctor_name;


---Which department haas highest patient load
SELECT 
	d.department_id,
	d.department_name,
	COUNT(a.patient_id) AS total_patient_load
	FROM department d
JOIN doctors doc
	ON d.department_id = doc.department_id
JOIN appointments a
	ON doc.doctor_id = a.doctor_id
GROUP BY 
	d.department_id,
	d.department_name;

--Operational workload analysis by Department
SELECT
	d.department_name,
	COUNT(a.appointment_id) AS total_appointments,
	COUNT(DISTINCT a.patient_id) AS total_patients,
	COUNT(DISTINCT doc.doctor_id) AS total_doctors,
	COUNT(a.appointment_id) * 1.0 / 
	COUNT(DISTINCT doc.doctor_id) AS workload_per_doctors
	FROM department d
	JOIN doctors doc 
		ON d.department_id = doc.department_id
	JOIN appointments a 
		ON doc.doctor_id = a.doctor_id
	GROUP BY d.department_name;


--Which treatment generates highest revenue
SELECT 
	t.treatment_type,
	SUM(t.treatment_cost) AS total_revenue 
FROM treatments t
GROUP BY t.treatment_type
ORDER BY total_revenue DESC;

---Monthly revenue Trend Query
SELECT 
	DATENAME(MONTH, payment_date) AS revenue_name,
	SUM(treatment_cost) AS total_revenue
	FROM billing
GROUP BY MONTH(payment_date),
			DATENAME(MONTH, payment_date)
ORDER BY total_revenue


--Completed KPI
SELECT 
	COUNT(CASE 
		WHEN status = 'completed'
		THEN 1
		END) AS completed_appointment
		FROM appointments;

--Cancelled KPI
SELECT 
	COUNT(CASE 
		WHEN status = 'cancelled'
		THEN 1
		END) AS cancelled_appointment
		FROM appointments;

--Pending KPI
SELECT 
	COUNT(CASE 
		WHEN status = 'pending'
		THEN 1
		END) AS pending_appointment
		FROM appointments;

--KPI TOP Revenue Doctor
	SELECT TOP 1
		doc.doctor_name,
		SUM(t.treatment_cost) AS total_revenue
		FROM treatments t
		JOIN doctors doc
			ON t.doctor_id = doc.doctor_id
		GROUP BY doc.doctor_name;
		
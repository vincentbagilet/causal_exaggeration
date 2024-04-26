#Functions that are used in several scripts
summarise_sim <- function(data, varying_params, true_effect) {
  data %>%
    mutate(signif = (p_value <= 0.05)) |>  
    group_by(across({{ varying_params }})) |>
    summarise(
      power = mean(signif, na.rm = TRUE)*100, 
      type_m = mean(ifelse(signif, abs(estimate/unique({{ true_effect }})), NA), na.rm = TRUE),
      # exag_ratio = mean(ifelse(signif, estimate/{{ true_effect }}, NA), na.rm = TRUE),
      bias_all = mean(estimate/{{ true_effect }}, na.rm = TRUE),
      bias_all_median = median(estimate/{{ true_effect }}, na.rm = TRUE),
      median_snr = median(abs(estimate/se), na.rm = TRUE),
      .groups	= "drop"
    ) |>  
    ungroup() 
} 
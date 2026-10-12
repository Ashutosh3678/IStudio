/// Administrative location choices used by discovery and profile onboarding.
/// Names follow the Government of India's state/UT naming convention. This is
/// reference data only; photographer results always come from the API.
class IndiaLocations {
  IndiaLocations._();

  static const Map<String, List<String>> districtsByState = {
    'Andhra Pradesh': ['Anantapur', 'Chittoor', 'East Godavari', 'Guntur', 'Kadapa', 'Krishna', 'Kurnool', 'Nellore', 'Prakasam', 'Srikakulam', 'Visakhapatnam', 'Vizianagaram', 'West Godavari'],
    'Arunachal Pradesh': ['Anjaw', 'Changlang', 'Dibang Valley', 'East Kameng', 'East Siang', 'Itanagar', 'Lohit', 'Lower Dibang Valley', 'Lower Subansiri', 'Papum Pare', 'Tawang', 'Tirap', 'Upper Siang', 'West Kameng', 'West Siang'],
    'Assam': ['Baksa', 'Barpeta', 'Cachar', 'Darrang', 'Dhemaji', 'Dhubri', 'Dibrugarh', 'Goalpara', 'Golaghat', 'Jorhat', 'Kamrup', 'Kamrup Metropolitan', 'Lakhimpur', 'Nagaon', 'Sivasagar', 'Sonitpur', 'Tinsukia'],
    'Bihar': ['Araria', 'Aurangabad', 'Begusarai', 'Bhagalpur', 'Bhojpur', 'Darbhanga', 'Gaya', 'Gopalganj', 'Jamui', 'Jehanabad', 'Katihar', 'Khagaria', 'Kishanganj', 'Madhepura', 'Madhubani', 'Muzaffarpur', 'Nalanda', 'Patna', 'Purnia', 'Rohtas', 'Saharsa', 'Samastipur', 'Saran', 'Sitamarhi', 'Siwan', 'Vaishali'],
    'Chhattisgarh': ['Bastar', 'Bilaspur', 'Durg', 'Janjgir-Champa', 'Jashpur', 'Korba', 'Koriya', 'Mahasamund', 'Raigarh', 'Raipur', 'Rajnandgaon', 'Surguja'],
    'Goa': ['North Goa', 'South Goa'],
    'Gujarat': ['Ahmedabad', 'Amreli', 'Anand', 'Bharuch', 'Bhavnagar', 'Gandhinagar', 'Jamnagar', 'Junagadh', 'Kachchh', 'Kheda', 'Mehsana', 'Patan', 'Rajkot', 'Surat', 'Vadodara', 'Valsad'],
    'Haryana': ['Ambala', 'Bhiwani', 'Faridabad', 'Gurugram', 'Hisar', 'Karnal', 'Kurukshetra', 'Panipat', 'Rewari', 'Rohtak', 'Sirsa', 'Sonipat', 'Yamunanagar'],
    'Himachal Pradesh': ['Bilaspur', 'Chamba', 'Hamirpur', 'Kangra', 'Kinnaur', 'Kullu', 'Mandi', 'Shimla', 'Sirmaur', 'Solan', 'Una'],
    'Jharkhand': ['Bokaro', 'Chatra', 'Deoghar', 'Dhanbad', 'Dumka', 'East Singhbhum', 'Giridih', 'Hazaribagh', 'Ranchi', 'Sahibganj', 'Seraikela Kharsawan', 'West Singhbhum'],
    'Karnataka': ['Bagalkot', 'Ballari', 'Belagavi', 'Bengaluru Urban', 'Bengaluru Rural', 'Bidar', 'Chamarajanagar', 'Chikkaballapur', 'Chikkamagaluru', 'Chitradurga', 'Dakshina Kannada', 'Davanagere', 'Dharwad', 'Hassan', 'Haveri', 'Kalaburagi', 'Kodagu', 'Kolar', 'Koppal', 'Mandya', 'Mysuru', 'Raichur', 'Shivamogga', 'Tumakuru', 'Udupi', 'Uttara Kannada', 'Vijayapura'],
    'Kerala': ['Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam', 'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta', 'Thiruvananthapuram', 'Thrissur', 'Wayanad'],
    'Manipur': ['Bishnupur', 'Chandel', 'Churachandpur', 'Imphal East', 'Imphal West', 'Senapati', 'Tamenglong', 'Thoubal', 'Ukhrul'],
    'Meghalaya': ['East Garo Hills', 'East Khasi Hills', 'Jaintia Hills', 'Ri-Bhoi', 'South Garo Hills', 'South West Khasi Hills', 'West Garo Hills', 'West Khasi Hills'],
    'Madhya Pradesh': ['Bhopal', 'Chhindwara', 'Gwalior', 'Indore', 'Jabalpur', 'Mandsaur', 'Morena', 'Rewa', 'Sagar', 'Satna', 'Ujjain', 'Vidisha'],
    'Maharashtra': ['Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara', 'Chandrapur', 'Dhule', 'Gadchiroli', 'Jalgaon', 'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban', 'Nagpur', 'Nanded', 'Nashik', 'Osmanabad', 'Palghar', 'Pune', 'Raigad', 'Ratnagiri', 'Sangli', 'Satara', 'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal'],
    'Odisha': ['Angul', 'Balangir', 'Balasore', 'Bargarh', 'Bhadrak', 'Cuttack', 'Dhenkanal', 'Ganjam', 'Jajpur', 'Kalahandi', 'Khordha', 'Koraput', 'Mayurbhanj', 'Puri', 'Rayagada', 'Sambalpur', 'Sundargarh'],
    'Punjab': ['Amritsar', 'Bathinda', 'Firozpur', 'Gurdaspur', 'Hoshiarpur', 'Jalandhar', 'Ludhiana', 'Mansa', 'Moga', 'Patiala', 'Sangrur', 'SAS Nagar', 'Tarn Taran'],
    'Rajasthan': ['Ajmer', 'Alwar', 'Banswara', 'Baran', 'Barmer', 'Bharatpur', 'Bhilwara', 'Bikaner', 'Bundi', 'Chittorgarh', 'Churu', 'Dausa', 'Dholpur', 'Dungarpur', 'Hanumangarh', 'Jaipur', 'Jaisalmer', 'Jalore', 'Jhalawar', 'Jhunjhunu', 'Jodhpur', 'Kota', 'Nagaur', 'Pali', 'Rajsamand', 'Sawai Madhopur', 'Sikar', 'Sirohi', 'Sri Ganganagar', 'Tonk', 'Udaipur'],
    'Tamil Nadu': ['Ariyalur', 'Chengalpattu', 'Chennai', 'Coimbatore', 'Cuddalore', 'Dharmapuri', 'Dindigul', 'Erode', 'Kanchipuram', 'Kanyakumari', 'Karur', 'Krishnagiri', 'Madurai', 'Nagapattinam', 'Namakkal', 'Nilgiris', 'Perambalur', 'Pudukkottai', 'Ramanathapuram', 'Salem', 'Sivaganga', 'Thanjavur', 'Theni', 'Thoothukudi', 'Tiruchirappalli', 'Tirunelveli', 'Tiruppur', 'Tiruvallur', 'Vellore', 'Viluppuram', 'Virudhunagar'],
    'Mizoram': ['Aizawl', 'Champhai', 'Kolasib', 'Lawngtlai', 'Lunglei', 'Mamit', 'Saiha', 'Serchhip'],
    'Nagaland': ['Dimapur', 'Kiphire', 'Kohima', 'Mokokchung', 'Mon', 'Peren', 'Phek', 'Tuensang', 'Wokha', 'Zunheboto'],
    'Sikkim': ['East Sikkim', 'North Sikkim', 'South Sikkim', 'West Sikkim'],
    'Telangana': ['Adilabad', 'Bhadradri Kothagudem', 'Hyderabad', 'Jagtial', 'Jangaon', 'Jayashankar Bhupalpally', 'Jogulamba Gadwal', 'Kamareddy', 'Karimnagar', 'Khammam', 'Komaram Bheem Asifabad', 'Mahabubabad', 'Mahbubnagar', 'Mancherial', 'Medak', 'Medchal-Malkajgiri', 'Mulugu', 'Nagarkurnool', 'Nalgonda', 'Narayanpet', 'Nirmal', 'Nizamabad', 'Peddapalli', 'Rajanna Sircilla', 'Rangareddy', 'Sangareddy', 'Siddipet', 'Suryapet', 'Vikarabad', 'Wanaparthy', 'Warangal', 'Yadadri Bhuvanagiri'],
    'Tripura': ['Dhalai', 'Gomati', 'Khowai', 'North Tripura', 'Sepahijala', 'South Tripura', 'Unakoti', 'West Tripura'],
    'Uttar Pradesh': ['Agra', 'Aligarh', 'Allahabad', 'Azamgarh', 'Bareilly', 'Basti', 'Bijnor', 'Bulandshahr', 'Etah', 'Faizabad', 'Farrukhabad', 'Firozabad', 'Ghaziabad', 'Gorakhpur', 'Jhansi', 'Kanpur Nagar', 'Lucknow', 'Mathura', 'Meerut', 'Moradabad', 'Muzaffarnagar', 'Noida', 'Prayagraj', 'Rampur', 'Saharanpur', 'Varanasi'],
    'Uttarakhand': ['Almora', 'Bageshwar', 'Chamoli', 'Champawat', 'Dehradun', 'Haridwar', 'Nainital', 'Pauri Garhwal', 'Pithoragarh', 'Rudraprayag', 'Tehri Garhwal', 'Udham Singh Nagar', 'Uttarkashi'],
    'West Bengal': ['Alipurduar', 'Bankura', 'Birbhum', 'Cooch Behar', 'Darjeeling', 'Hooghly', 'Howrah', 'Jalpaiguri', 'Jhargram', 'Kolkata', 'Malda', 'Murshidabad', 'Nadia', 'North 24 Parganas', 'Paschim Medinipur', 'Purba Medinipur', 'South 24 Parganas', 'Uttar Dinajpur'],
    'Andaman and Nicobar Islands': ['Nicobar', 'North and Middle Andaman', 'South Andaman'],
    'Chandigarh': ['Chandigarh'],
    'Dadra and Nagar Haveli and Daman and Diu': ['Dadra and Nagar Haveli', 'Daman', 'Diu'],
    'Delhi': ['Central Delhi', 'East Delhi', 'New Delhi', 'North Delhi', 'North East Delhi', 'North West Delhi', 'Shahdara', 'South Delhi', 'South East Delhi', 'South West Delhi', 'West Delhi'],
    'Jammu and Kashmir': ['Anantnag', 'Baramulla', 'Budgam', 'Jammu', 'Kathua', 'Kupwara', 'Pulwama', 'Rajouri', 'Srinagar', 'Udhampur'],
    'Ladakh': ['Kargil', 'Leh'],
    'Lakshadweep': ['Lakshadweep'],
    'Puducherry': ['Karaikal', 'Mahe', 'Puducherry', 'Yanam'],
  };

  static List<String> get states => districtsByState.keys.toList(growable: false);
}

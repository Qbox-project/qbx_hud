let maxSpeedCounter = 350;

document.addEventListener("DOMContentLoaded", function () {
    window.addEventListener("message", function (event) {
        if (event.data.update == true) {
            const Data = event.data.data;
            for (let i = 0; i < Data.length; i++) {
                const dataItem = Data[i];
                switch (dataItem.type) {
                    case 'compass':
                        setCompass(dataItem.show, dataItem.heading, dataItem.street, dataItem.street2);
                        break;
                    case 'vehiclehud':
                        document.getElementsByClassName('vehicle-hud')[0].style.opacity = dataItem.show ? 1 : 0;
                        break;
                    case 'speed':
                        setSpeed(dataItem.speed);
                        break;
                    case 'speedmax':
                        maxSpeedCounter = dataItem.speed;
                        break;
                    case 'gauge':
                        setGauge(dataItem.value, dataItem.name, dataItem.show);
                        break;
                    case 'dashboardlights':
                        setDashboardLight(dataItem);
                        break;
                    case 'progress':
                        setProgress(dataItem.value, `progress-${dataItem.name}`, dataItem.option);
                        break;
                    case 'seatbelt':
                        setSeatbelt(dataItem.value, dataItem.harness);
                        break;
                    case 'showHud':
                        document.getElementsByTagName('body')[0].style.opacity = dataItem.value ? 1 : 0;
                        break;
                    case 'balance':
                        if (dataItem.set) {
                            if (typeof dataItem.amount === 'number') {
                                moneyChange(dataItem.amount, dataItem.isCash, dataItem.isNegative);
                            }
                            setTimeout(() => {
                                setBalance(dataItem.value, dataItem.isCash);
                            }, dataItem.amount && 2500 || 0);
                            break;
                        };
                        showMoney(dataItem.isCash);
                        break;
                    default:
                        break;
                }
            }
        }
    });
});

function setProgress(percent, className, option) {
    let circle = document.getElementById(className);
    if (circle === undefined) return;
    if (percent !== undefined) {
        Math.min(100, Math.max(0, percent));
        let circumference = circle.r.baseVal.value * 2 * Math.PI;
        //Why 0.81? i don't know, but it works
        let offset = circumference - ((percent / 100) * 0.81) * circumference;

        circle.style.strokeDasharray = circumference;
        circle.style.strokeDashoffset = offset;
    }
    if (option !== undefined) {
        for (var key in option) {
            circle.style[key] = option[key] || null;
        }
    }
}

function setBalance(balance, isCash) {
    if (balance === undefined || isCash === undefined) return;
    if (balance < 0) balance = 0;

    if (isCash) {
        document.getElementById('cash-balance').innerHTML = balance.toLocaleString('us-US', { style: 'currency', maximumFractionDigits: 0, compactDisplay: "short", currency: 'USD' });
    } else {
        document.getElementById('bank-balance').innerHTML = balance.toLocaleString('us-US', { style: 'currency', maximumFractionDigits: 0, compactDisplay: "short", currency: 'USD' });
    }
}

function setSeatbelt(toggle, harness) {
    if (toggle === undefined) return;
    document.getElementById('seatbelt').style.color = harness && '#5555aaff' || toggle && '#55aa55ff' || null;
}

function setSpeed(speed) {
    if (typeof speed !== 'number') return;
    if (speed > maxSpeedCounter) speed = maxSpeedCounter; // Should never happen but who knows with that game
    speed = Math.round(speed);
    setSpeedProgress(speed/maxSpeedCounter*100);
    document.getElementById('speed').innerHTML = speed;
}

function setGauge(percentage, name, show) {
    if (percentage === undefined) return;
    let gauge = document.getElementById(name);
    if (gauge === undefined) return;
    if (show !== undefined) {
        document.getElementById(name).style.opacity = show ? 1 : 0;
    }
    if (percentage > 100) percentage = 100;
    let circle = document.getElementById('progress-' + name);
    if (circle === undefined) return;
    let circumference = circle.r.baseVal.value * 2 * Math.PI;
    let offset = circumference - (percentage / 100 * 0.7) * circumference;

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = offset;

    if (name === 'fuel') {
        document.getElementById('progress-fuel').style.stroke = percentage > 30 ? '#ffffff' : percentage > 15 ? '#f39c12' : '#a40000';
    }
}

/* thanks bing AI */
function setSpeedProgress(percentage) {
    if (percentage === undefined) return;
    if (percentage > 100) percentage = 100;
    let circle = document.getElementById('progress-speed');
    if (circle === undefined) return;
    let circumference = circle.r.baseVal.value * 2 * Math.PI;
    let offset = circumference - (percentage / 100 * 0.7) * circumference;

    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = offset;
}

function setCompass(show, heading, street, zone) {
    if (show) document.getElementsByClassName("compass-hud")[0].style.opacity = show ? 1 : 0;
    if (heading) document.getElementById('azimuth').innerHTML = heading;
    if (street) document.getElementById('street').innerHTML = street;
    if (zone) document.getElementById('zone').innerHTML = zone;
}

function setDashboardLight(data) {
    if (data.indicatorL !== undefined) {
        if (data.indicatorL) {
            document.getElementById('indicatorL').classList.add('indicator-active');
        } else {
            document.getElementById('indicatorL').classList.remove('indicator-active');
        }
    }
    if (data.indicatorR !== undefined) {
        if (data.indicatorR) {
            document.getElementById('indicatorR').classList.add('indicator-active');
        } else {
            document.getElementById('indicatorR').classList.remove('indicator-active');
        }
    }
    if (data.lowbeam !== undefined) {
        document.getElementById('lowbeam').style.fill = data.lowbeam && '#0984e3' || '';
        document.getElementById('lowbeam').style.opacity = data.lowbeam && '1.0' || '0.2';
        if (data.lowbeam && !data.highbeam) {
            data.highbeam = true;
        }
    }
    if (data.highbeam !== undefined) {
        document.getElementById('highbeam').style.fill = data.highbeam && '#2ecc71' || '';
        document.getElementById('highbeam').style.opacity = data.highbeam && '1.0' || '0.2';
    }
}

function showMoney(isCash) {
    document.getElementById(isCash && 'cash' || 'bank').style.display = 'flex';
    setTimeout(() => {
        document.getElementById(isCash && 'cash' || 'bank').style.display = 'none';
    }, 2500);
}

function moneyChange(amount, isCash, isNegative) {
    if (amount === undefined) return;
    showMoney(isCash)
    document.getElementById(isCash && 'cash-change' || 'bank-change').style.display = 'block';
    if (isNegative) {
        document.getElementById(isCash && 'cash-change' || 'bank-change').classList.remove('positive-money');
        document.getElementById(isCash && 'cash-change' || 'bank-change').classList.add('negative-money');
    } else {
        document.getElementById(isCash && 'cash-change' || 'bank-change').classList.remove('negative-money');
        document.getElementById(isCash && 'cash-change' || 'bank-change').classList.add('positive-money');
    }

    document.getElementById(isCash && 'cash-change' || 'bank-change').innerHTML = amount.toLocaleString('us-US', { style: 'currency', maximumFractionDigits: 0, compactDisplay: "short", currency: 'USD' });
    setTimeout(() => {
        document.getElementById(isCash && 'cash-change' || 'bank-change').innerHTML = '';
        document.getElementById(isCash && 'cash-change' || 'bank-change').style.display = 'none';
    }, 2500);
}
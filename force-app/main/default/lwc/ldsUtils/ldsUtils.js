/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrorsUpgraded(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (error.body && error.body.duplicateResults && error.body.duplicateResults.length > 0) {
                    return error.body.duplicateResults.map((e) => e.message);
                }

                else if (error.body && error.body.fieldErrors && error.body.fieldErrors.length > 0 && Array.isArray(error.body.fieldErrors)) {
                    return error.body.fieldErrors.map((e) => e.message);
                }

                else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && Array.isArray(error.body.pageErrors)) {
                    return error.body.pageErrors.map((e) => e.message);
                }

                else if (error.body && Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (error.message && typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * Update by viral to handle fieldErrors
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */

export function reduceErrorsUpgradedAdvanced(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                console.log('--error--',error);
                // UI API read errors
                if (error.body && error.body.duplicateResults && error.body.duplicateResults.length > 0) {
                     console.log('--error.body.duplicateResults--',error.body.duplicateResults);
                    return error.body.duplicateResults.map((e) => e.message);
                }
                else if (error.body && error.body.fieldErrors && error.body.fieldErrors.length > 0) {
                     console.log('--error.body.fieldErrors--',error.body.fieldErrors);
					let errormsg = [];
					for(var fieldName in error.body.fieldErrors){
						error.body.fieldErrors[fieldName].forEach((e)=> errormsg.push(e.message));
					}
					return errormsg;
                }
                else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && Array.isArray(error.body.pageErrors)) {
                    console.log('--error.body.pageErrors--',error.body.pageErrors);
                    return error.body.pageErrors.map((e) => e.message);
                }

                else if (error.body && Array.isArray(error.body)) {
                    console.log('--error.body--',error.body.pageErrors);
                    return error.body.map((e) => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (error.message && typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}
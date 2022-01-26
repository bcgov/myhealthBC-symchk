import React from 'react';
import PropTypes from 'prop-types';
import { Field } from 'formik';

export const RadioField = props => {
  const { name, text, label, value, onChange, description, checked } = props;
  return (
    <label className='flex items-center cursor-pointer leading-none py-3'>
      <Field
        name={name}
        label={label || name}
        type='radio'
        value={value}
        description={description || name}
        onChange={onChange}
        className='mr-2 h-5 w-5 min-w-5 cursor-pointer hover:border-2'
        checked={checked}
      />
      <span id={name + value} className='ml-3'>
        {text}
      </span>
    </label>
  );
};

RadioField.propTypes = {
  name: PropTypes.string.isRequired,
  label: PropTypes.string,
  value: PropTypes.string.isRequired,
  text: PropTypes.string,
  onChange: PropTypes.func,
  description: PropTypes.string,
  checked: PropTypes.bool,
};
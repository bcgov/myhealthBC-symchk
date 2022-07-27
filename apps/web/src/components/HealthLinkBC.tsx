import React from 'react';
import { useTranslation, Trans } from 'react-i18next';
import PropTypes from 'prop-types';

export const HealthLinkBC = ({ linkForChildren, linkForAdults, translationKey }) => {
  const { t } = useTranslation('severity');
  return (
    <Trans t={t} i18nKey={translationKey}>
      <div className='text-base text-bcGray mb-2'>
        Input title here
        <ul className='list-disc pl-6'>
          <li>
            <a
              className='underline text-bcBlueLink'
              href={linkForChildren}
              target='_blank'
              rel='noreferrer'
            >
              Children age 11 and younger
            </a>
          </li>
          <li>
            <a
              className='underline text-bcBlueLink'
              href={linkForAdults}
              target='_blank'
              rel='noreferrer'
            >
              People age 12 and older
            </a>
          </li>
        </ul>
      </div>
    </Trans>
  );
};

HealthLinkBC.propTypes = {
  linkForChildren: PropTypes.string.isRequired,
  linkForAdults: PropTypes.string.isRequired,
  translationKey: PropTypes.string.isRequired,
};
